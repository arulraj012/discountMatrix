const cds = require('@sap/cds');
const csv = require('csv-parser');
const { Readable } = require('stream');

function normalizeRow(row) {
  const clean = {};
  for (const key of Object.keys(row)) {
    const normalizedKey = key.replace(/^\uFEFF/, '').trim().toUpperCase();
    clean[normalizedKey] = row[key];
  }
  return clean;
}

module.exports = cds.service.impl(async (srv) => {
  const { DiscountMatrix } = srv.entities;

  // --------------------------------------------------------
  // Before CREATE or UPDATE - VALIDATION LOGIC
  // --------------------------------------------------------
  srv.before(["CREATE", "UPDATE"], 'DiscountMatrix', async (req) => {
    const {
      sequence,
      salesOrg,
      distributionChannel,
      division,
      salesOffice,
      businessUserRole,
      approverPartyRole,
      approverEmployeeId,
      minPercentage,
      maxPercentage,
      active
    } = req.data;

    console.log(' update discount entries action triggered' + minPercentage, maxPercentage);
    // 1. Min % <= Max %
    const min = Number(minPercentage);
    const max = Number(maxPercentage);

    if (min > max) {
      req.error(
        400,
        `Minimum Discount % (${min}) cannot be greater than Maximum Discount % (${max})`
      );
    }


    // 2. Approver Employee ID is mandatory for active rules
    if (active && !approverEmployeeId) {
      req.error(400, "Approver Employee ID is required for active approval rules.");
    }

    // 3. Validate employeeId format (e.g., "80001234")
    if (approverEmployeeId && !/^\d{1,15}$/.test(approverEmployeeId)) {
      req.error(400, "Approver Employee ID must be 1 to 15 digits (e.g., 80001234).");
    }

    // 4. Prevent duplicate active rules for same org + approver role
    if (active) {
      const existing = await SELECT.from(DiscountMatrix)
        .where({
          sequence,
          salesOrg,
          distributionChannel,
          division,
          salesOffice,
          businessUserRole,
          approverPartyRole,
          active: true
        });

      if (existing.length > 0 && existing[0].ID !== req.data.ID) {
        req.error(
          400,
          `An active rule already exists for role ${approverPartyRole} in this sales area.`
        );
      }
    }

    // --------------------------------------------------
    // 5 Fetch Employee UUID from Sales Cloud V2
    // --------------------------------------------------
    if (approverEmployeeId) {
      try {
        const sscv2EmployeeSrv = await cds.connect.to('Sscv2EmployeeService');
        const employee = await sscv2EmployeeSrv.getEmployeeByDisplayId(id = approverEmployeeId);
        console.log("SalesQuoteAutoflow employee" + employee);
        if (!employee) {
          req.error(
            400,
            `No employee found in Sales Cloud for employeeId ${approverEmployeeId}`
          );
        } else {
          req.data.approverEmployeeUUID = employee.employeeId;
        }


      } catch (e) {
        req.error(400, e.message);
      }
    }

    // 6. Overlapping discount ranges not allowed
    const overlaps = await SELECT.from(DiscountMatrix)
      .where({
        sequence,
        salesOrg,
        distributionChannel,
        division,
        salesOffice,
        businessUserRole,
        approverPartyRole,
        active: true
      })
      .and(`(minPercentage <= ${maxPercentage} AND maxPercentage >= ${minPercentage})`);

    if (overlaps.length > 0 && overlaps[0].ID !== req.data.ID) {
      req.error(400, "Overlapping discount range exists for this role.");
    }
  });

  srv.on('uploadDiscountCSV', async (req) => {

    console.log(' uploadDiscountCSV action triggered' + req.data);

    const { csvContent } = req.data;

    if (!csvContent) {
      console.error(' csvContent is missing in request');
      req.error(400, 'csvContent is required');
    }

    console.log(' csvContent length:', csvContent.length);
    console.log(
      ' csvContent prefix:',
      csvContent.substring(0, 40)
    );

    // 1️ Strip Base64 prefix
    const base64Data = csvContent.replace(
      /^data:text\/csv;base64,/,
      ''
    );

    console.log('Base64 prefix stripped');
    console.log(' Base64 data length:', base64Data.length);

    // 2️ Decode Base64 → CSV text
    const csvText = Buffer
      .from(base64Data, 'base64')
      .toString('utf8');

    console.log(' Base64 decoded to CSV text');
    console.log(
      'CSV preview:\n',
      csvText.split('\n').slice(0, 3).join('\n')
    );

    // 3️ Parse CSV
    const rows = [];
    console.log(' Starting CSV parsing');

    await new Promise((resolve, reject) => {
      Readable.from(csvText)
        .pipe(csv())
        .on('data', (row) => {
          rows.push(row);
        })
        .on('end', () => {
          console.log(` CSV parsing completed. Rows parsed: ${rows.length}`);
          resolve();
        })
        .on('error', (err) => {
          console.error(' CSV parsing error:', err);
          reject(err);
        });
    });

    if (rows.length === 0) {
      console.warn('CSV parsed but no data rows found');
    }

    //  Start transaction
    console.log(' Starting CAP transaction');
    const tx = cds.tx(req);

    let successCount = 0;
    let errorCount = 0;

    for (const [index, rawRow] of rows.entries()) {
      try {
        const row = normalizeRow(rawRow);
        console.log(` Processing row ${index + 2}`, row);
        const id = row.ID?.trim();
        console.log('row id =', id);
        console.log('row SALESORG =', row.SALESORG);

        if (!row.SALESORG) {
          console.warn(
            `Row ${index + 2} skipped: Missing SALESORG or SEQUENCE`
          );
          errorCount++;
          continue;
        }

        const approvalLevel = row.APPROVALLEVEL?.trim();

        if (!approvalLevel) {
          throw new Error(`Row ${index + 2}: APPROVALLEVEL is missing`);
        }

        if (!/^0\d$/.test(approvalLevel)) {
          console.warn(
            `Row ${index + 2} Invalid APPROVALLEVEL '${approvalLevel}'. Expected format '01', '02', etc.`
          );
          errorCount++;
          continue;
        }


        const existing = await tx.run(
          SELECT.one
            .from('DiscountMatrixSrv.discountMatrix')
            .where({ ID: id })
        );
        console.log('existing row' + existing);

        await tx.run(
          UPSERT.into('DiscountMatrixSrv.DiscountMatrix').entries({
            ID: row.ID,
            salesOrg: row.SALESORG,
            distributionChannel: row.DISTRIBUTIONCHANNEL,

            division: row.DIVISION,
            salesOffice: row.SALESOFFICE,
            businessUserRole: row.BUSINESSUSERROLE,
            approverEmployeeId: row.APPROVEREMPLOYEEID,
            approverPartyRole: row.APPROVERPARTYROLE,
            minPercentage: Number(row.MINPERCENTAGE),
            maxPercentage: Number(row.MAXPERCENTAGE),
            approvalLevel: row.APPROVALLEVEL,
            active: String(row.ACTIVE).toLowerCase() === 'true'
          })
        );

        successCount++;

      } catch (e) {
        console.error(
          `Error processing row ${index + 2}:`,
          e.message
        );
        errorCount++;
      }
    }

    // 5️⃣ Commit transaction
    await tx.commit();
    console.log('Transaction committed');

    console.log(' uploadDiscountCSV completed');
    console.log('Success count:', successCount);
    console.log(' Error count:', errorCount);

    return {
      successCount,
      errorCount
    };
  });



});
