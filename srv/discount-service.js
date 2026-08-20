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

// Transform organizational unit data to sales organization format
function toSalesOrganization(data) {
  return {
    SalesOrgCode: data.displayId,
    SalesOrgName: data.name || data.displayId
  };
}

// Transform distribution channel data
function toDistributionChannel(data) {
  return {
    DistChannelCode: data.code,
    DistChannelName: data.description || data.code
  };
}

// Transform division data
function toDivision(data) {
  return {
    DivisionCode: data.code,
    DivisionName: data.description || data.code
  };
}

// Transform sales office data
function toSalesOffice(data) {
  return {
    SalesOfficeCode: data.displayId,
    SalesOfficeName: data.name || data.displayId
  };
}

// Transform employee data
function toEmployee(data) {
  return {
    EmployeeId: data.id,
    EmployeeDisplayId: data.employeeDisplayId,
    EmployeeName: data.formattedName || data.employeeDisplayId
  };
}

// Helper function to extract search terms from OData request
function extractSearchTerms(req) {
  const searchTerms = [];
  
  try {
    // Check for $search parameter
    if (req.query.SELECT && req.query.SELECT.search) {
      const searchValue = req.query.SELECT.search;
      if (typeof searchValue === 'string' && searchValue.length > 0) {
        searchTerms.push(searchValue.toLowerCase());
      } else if (Array.isArray(searchValue)) {
        for (const s of searchValue) {
          if (typeof s === 'string' && s.length > 0) {
            searchTerms.push(s.toLowerCase());
          } else if (s && typeof s === 'object' && s.val) {
            // Handle object with val property
            const val = String(s.val);
            if (val.length > 0) {
              searchTerms.push(val.toLowerCase());
            }
          }
        }
      } else if (searchValue && typeof searchValue === 'object') {
        // Handle object format
        if (searchValue.val) {
          const val = String(searchValue.val);
          if (val.length > 0) {
            searchTerms.push(val.toLowerCase());
          }
        }
      }
    }
    
    // Check for filter conditions in WHERE clause
    if (req.query.SELECT && req.query.SELECT.where) {
      const extractFromWhere = (where) => {
        if (!where) return;
        if (!Array.isArray(where)) {
          // Handle single condition object
          if (where.val !== undefined) {
            const val = String(where.val);
            if (val && val.length > 0) {
              const cleanVal = val.replace(/\*/g, '').toLowerCase();
              if (cleanVal.length > 0) {
                searchTerms.push(cleanVal);
              }
            }
          }
          return;
        }
        for (const condition of where) {
          if (condition && condition.val !== undefined) {
            // Handle string values that might be search terms
            const val = String(condition.val);
            if (val && val.length > 0) {
              // Remove wildcards and convert to lowercase for matching
              const cleanVal = val.replace(/\*/g, '').toLowerCase();
              if (cleanVal.length > 0) {
                searchTerms.push(cleanVal);
              }
            }
          } else if (condition && condition.xpr) {
            // Recursively handle nested expressions
            extractFromWhere(condition.xpr);
          } else if (Array.isArray(condition)) {
            extractFromWhere(condition);
          }
        }
      };
      extractFromWhere(req.query.SELECT.where);
    }
  } catch (err) {
    console.error("Error extracting search terms:", err.message);
    // Return empty array on error - will show all results
  }
  
  return searchTerms;
}

// Helper function to filter results based on search terms
function filterBySearchTerms(data, searchTerms, searchFields) {
  if (!searchTerms || searchTerms.length === 0) {
    return data;
  }
  
  return data.filter(item => {
    return searchTerms.some(term => {
      return searchFields.some(field => {
        const fieldValue = item[field];
        if (fieldValue) {
          return String(fieldValue).toLowerCase().includes(term);
        }
        return false;
      });
    });
  });
}

module.exports = cds.service.impl(async (srv) => {
  const { DiscountMatrix, BusinessUserRoles, ApproverPartyRoles, SalesOrganizations, DistributionChannels, Divisions, SalesOffices, Employees } = srv.entities;

  // Cache for role lookups
  let businessUserRolesCache = null;
  let approverPartyRolesCache = null;

  // Helper function to get business user roles
  async function getBusinessUserRoles() {
    if (!businessUserRolesCache) {
      businessUserRolesCache = await SELECT.from(BusinessUserRoles);
    }
    return businessUserRolesCache;
  }

  // Helper function to get approver party roles
  async function getApproverPartyRoles() {
    if (!approverPartyRolesCache) {
      approverPartyRolesCache = await SELECT.from(ApproverPartyRoles);
    }
    return approverPartyRolesCache;
  }

  // --------------------------------------------------------
  // READ handler for Sales Organizations - Fetch from Sales Cloud V2 API
  // --------------------------------------------------------
  srv.on('READ', SalesOrganizations, async (req) => {
    try {
      console.log("Fetching Sales Organizations from Sales Cloud V2 API");
      console.log("Request query:", JSON.stringify(req.query, null, 2));
      
      // Extract search terms from the request
      const searchTerms = extractSearchTerms(req);
      console.log("Extracted search terms:", searchTerms);
      
      const orgUnitApi = await cds.connect.to("Organizational.Unit.Service");
      
      // Build the filter - only filter by isSalesOrganization and ACTIVE status
      // Removed date validity filter to get all sales organizations
      const filterString = `currentFunctions/isSalesOrganization eq true and lifeCycleStatus eq ACTIVE`;
      
      console.log("Sales Org API Filter:", filterString);
      
      // Build the URL path with query parameters - no encoding needed
      const url = `/organizationalUnits?$filter=${filterString}&$select=displayId,externalId,externalIds,id,name,validFrom,validTo&$top=100&$orderby=name asc&$count=true`;
      
      console.log("Sales Org API URL:", url);
      
      // Use simple send() with method and path - CAP's REST adapter will handle encoding
      const response = await orgUnitApi.send('GET', url);
      
      console.log("Sales Org API Response type:", typeof response);
      if (response) {
        console.log("Sales Org API Response:", JSON.stringify(response, null, 2).substring(0, 500));
      }
      
      // Handle different response formats
      let data = [];
      if (response) {
        if (Array.isArray(response)) {
          // Response is directly an array
          data = response;
        } else if (response.value && Array.isArray(response.value)) {
          // Response has a value property with array
          data = response.value;
        } else if (typeof response === 'object' && !response.error) {
          // Response might be a single object
          if (response.displayId) {
            data = [response];
          }
        }
      }
      
      if (data.length > 0) {
        let salesOrgs = data.map(toSalesOrganization);
        console.log(`Found ${salesOrgs.length} sales organizations before filtering`);
        
        // Apply search filtering if search terms are present
        if (searchTerms.length > 0) {
          salesOrgs = filterBySearchTerms(salesOrgs, searchTerms, ['SalesOrgCode', 'SalesOrgName']);
          console.log(`After filtering: ${salesOrgs.length} sales organizations match search terms`);
        }
        
        return salesOrgs;
      }
      
      console.log("No sales organizations found in response");
      return [];
    } catch (err) {
      console.error("Error fetching sales organizations:", err.message);
      console.error("Error stack:", err.stack);
      // Return empty array on error to prevent UI crash
      return [];
    }
  });

  // --------------------------------------------------------
  // READ handler for Distribution Channels - Fetch from Sales Cloud V2 API
  // --------------------------------------------------------
  srv.on('READ', DistributionChannels, async (req) => {
    try {
      console.log("Fetching Distribution Channels from Sales Cloud V2 API");
      console.log("Request query:", JSON.stringify(req.query, null, 2));
      
      // Extract search terms from the request
      const searchTerms = extractSearchTerms(req);
      console.log("Extracted search terms:", searchTerms);
      
      const orgUnitApi = await cds.connect.to("Organizational.Unit.Service");
      
      // Build the URL path with query parameters
      const url = `/distributionChannels?$count=true&$orderby=code asc&$top=100`;
      
      console.log("Distribution Channels API URL:", url);
      
      // Use simple send() with method and path - CAP's REST adapter will handle encoding
      const response = await orgUnitApi.send('GET', url);
      
      console.log("Distribution Channels API Response type:", typeof response);
      if (response) {
        console.log("Distribution Channels API Response:", JSON.stringify(response, null, 2).substring(0, 500));
      }
      
      // Handle different response formats
      let data = [];
      if (response) {
        if (Array.isArray(response)) {
          data = response;
        } else if (response.value && Array.isArray(response.value)) {
          data = response.value;
        } else if (typeof response === 'object' && !response.error) {
          if (response.code) {
            data = [response];
          }
        }
      }
      
      if (data.length > 0) {
        let channels = data.map(toDistributionChannel);
        console.log(`Found ${channels.length} distribution channels before filtering`);
        
        // Apply search filtering if search terms are present
        if (searchTerms.length > 0) {
          channels = filterBySearchTerms(channels, searchTerms, ['DistChannelCode', 'DistChannelName']);
          console.log(`After filtering: ${channels.length} distribution channels match search terms`);
        }
        
        return channels;
      }
      
      console.log("No distribution channels found in response");
      return [];
    } catch (err) {
      console.error("Error fetching distribution channels:", err.message);
      console.error("Error stack:", err.stack);
      return [];
    }
  });

  // --------------------------------------------------------
  // READ handler for Divisions - Fetch from Sales Cloud V2 API
  // --------------------------------------------------------
  srv.on('READ', Divisions, async (req) => {
    try {
      console.log("Fetching Divisions from Sales Cloud V2 API");
      console.log("Request query:", JSON.stringify(req.query, null, 2));
      
      // Extract search terms from the request
      const searchTerms = extractSearchTerms(req);
      console.log("Extracted search terms:", searchTerms);
      
      const orgUnitApi = await cds.connect.to("Organizational.Unit.Service");
      
      // Build the URL path with query parameters
      const url = `/divisions?$count=true&$orderby=code asc&$top=100`;
      
      console.log("Divisions API URL:", url);
      
      // Use simple send() with method and path - CAP's REST adapter will handle encoding
      const response = await orgUnitApi.send('GET', url);
      
      console.log("Divisions API Response type:", typeof response);
      if (response) {
        console.log("Divisions API Response:", JSON.stringify(response, null, 2).substring(0, 500));
      }
      
      // Handle different response formats
      let data = [];
      if (response) {
        if (Array.isArray(response)) {
          data = response;
        } else if (response.value && Array.isArray(response.value)) {
          data = response.value;
        } else if (typeof response === 'object' && !response.error) {
          if (response.code) {
            data = [response];
          }
        }
      }
      
      if (data.length > 0) {
        let divisions = data.map(toDivision);
        console.log(`Found ${divisions.length} divisions before filtering`);
        
        // Apply search filtering if search terms are present
        if (searchTerms.length > 0) {
          divisions = filterBySearchTerms(divisions, searchTerms, ['DivisionCode', 'DivisionName']);
          console.log(`After filtering: ${divisions.length} divisions match search terms`);
        }
        
        return divisions;
      }
      
      console.log("No divisions found in response");
      return [];
    } catch (err) {
      console.error("Error fetching divisions:", err.message);
      console.error("Error stack:", err.stack);
      return [];
    }
  });

  // --------------------------------------------------------
  // READ handler for Sales Offices - Fetch from Sales Cloud V2 API
  // --------------------------------------------------------
  srv.on('READ', SalesOffices, async (req) => {
    try {
      console.log("Fetching Sales Offices from Sales Cloud V2 API");
      console.log("Request query:", JSON.stringify(req.query, null, 2));
      
      // Extract search terms from the request
      const searchTerms = extractSearchTerms(req);
      console.log("Extracted search terms:", searchTerms);
      
      const orgUnitApi = await cds.connect.to("Organizational.Unit.Service");
      
      // Build the filter - only filter by isSalesOffice and ACTIVE status
      // Removed date validity filter to get all sales offices
      const filterString = `currentFunctions/isSalesOffice eq true and lifeCycleStatus eq ACTIVE`;
      
      console.log("Sales Office API Filter:", filterString);
      
      // Build the URL path with query parameters - no encoding needed
      const url = `/organizationalUnits?$filter=${filterString}&$select=displayId,externalId,externalIds,id,name,validFrom,validTo&$top=100&$orderby=name asc&$count=true`;
      
      console.log("Sales Office API URL:", url);
      
      // Use simple send() with method and path - CAP's REST adapter will handle encoding
      const response = await orgUnitApi.send('GET', url);
      
      console.log("Sales Office API Response type:", typeof response);
      if (response) {
        console.log("Sales Office API Response:", JSON.stringify(response, null, 2).substring(0, 500));
      }
      
      // Handle different response formats
      let data = [];
      if (response) {
        if (Array.isArray(response)) {
          // Response is directly an array
          data = response;
        } else if (response.value && Array.isArray(response.value)) {
          // Response has a value property with array
          data = response.value;
        } else if (typeof response === 'object' && !response.error) {
          // Response might be a single object
          if (response.displayId) {
            data = [response];
          }
        }
      }
      
      if (data.length > 0) {
        let salesOffices = data.map(toSalesOffice);
        console.log(`Found ${salesOffices.length} sales offices before filtering`);
        
        // Apply search filtering if search terms are present
        if (searchTerms.length > 0) {
          salesOffices = filterBySearchTerms(salesOffices, searchTerms, ['SalesOfficeCode', 'SalesOfficeName']);
          console.log(`After filtering: ${salesOffices.length} sales offices match search terms`);
        }
        
        return salesOffices;
      }
      
      console.log("No sales offices found in response");
      return [];
    } catch (err) {
      console.error("Error fetching sales offices:", err.message);
      console.error("Error stack:", err.stack);
      // Return empty array on error to prevent UI crash
      return [];
    }
  });

  // --------------------------------------------------------
  // READ handler for Employees - Fetch from Sales Cloud V2 API
  // Used for Approver Employee ID value help
  // --------------------------------------------------------
  srv.on('READ', Employees, async (req) => {
    try {
      console.log("Fetching Employees from Sales Cloud V2 API");
      console.log("Request query:", JSON.stringify(req.query, null, 2));
      
      // Extract search terms from the request
      const searchTerms = extractSearchTerms(req);
      console.log("Extracted search terms:", searchTerms);
      
      const employeeApi = await cds.connect.to("Employee.Service");
      
      // Get current date in YYYY-MM-DD format for validity check
      const today = new Date().toISOString().split('T')[0];
      
      // Build the filter for active employees
      const filterString = `(employeeTypes/validFrom le ${today}) and (employeeTypes/validTo ge ${today}) and (isBusinessPurposeCompleted eq false)`;
      
      console.log("Employees API Filter:", filterString);
      
      // Build the URL path with query parameters
      const url = `/employees?$filter=${filterString}&$select=employeeDisplayId,formattedName,id&$top=50&$orderby=formattedName asc&$count=true`;
      
      console.log("Employees API URL:", url);
      
      // Use simple send() with method and path - CAP's REST adapter will handle encoding
      const response = await employeeApi.send('GET', url);
      
      console.log("Employees API Response type:", typeof response);
      if (response) {
        console.log("Employees API Response:", JSON.stringify(response, null, 2).substring(0, 500));
      }
      
      // Handle different response formats
      let data = [];
      if (response) {
        if (Array.isArray(response)) {
          data = response;
        } else if (response.value && Array.isArray(response.value)) {
          data = response.value;
        } else if (typeof response === 'object' && !response.error) {
          if (response.id) {
            data = [response];
          }
        }
      }
      
      if (data.length > 0) {
        let employees = data.map(toEmployee);
        console.log(`Found ${employees.length} employees before filtering`);
        
        // Apply search filtering if search terms are present
        if (searchTerms.length > 0) {
          employees = filterBySearchTerms(employees, searchTerms, ['EmployeeDisplayId', 'EmployeeName']);
          console.log(`After filtering: ${employees.length} employees match search terms`);
        }
        
        return employees;
      }
      
      console.log("No employees found in response");
      return [];
    } catch (err) {
      console.error("Error fetching employees:", err.message);
      console.error("Error stack:", err.stack);
      // Return empty array on error to prevent UI crash
      return [];
    }
  });

  // --------------------------------------------------------
  // Before READ - Apply default sorting by salesOrg, distributionChannel, division
  // --------------------------------------------------------
  srv.before('READ', 'DiscountMatrix', async (req) => {
    // Add default ordering if no ordering is specified
    if (!req.query.SELECT.orderBy || req.query.SELECT.orderBy.length === 0) {
      req.query.SELECT.orderBy = [
        { ref: ['salesOrg'], sort: 'asc' },
        { ref: ['distributionChannel'], sort: 'asc' },
        { ref: ['division'], sort: 'asc' }
      ];
    }
  });

  // --------------------------------------------------------
  // After READ - Enrich with role names
  // --------------------------------------------------------
  srv.after('READ', 'DiscountMatrix', async (results, req) => {
    if (!results) return;
    
    const data = Array.isArray(results) ? results : [results];
    if (data.length === 0) return;

    // Get role lookups
    const businessRoles = await getBusinessUserRoles();
    const approverRoles = await getApproverPartyRoles();

    // Create lookup maps
    const businessRoleMap = new Map(businessRoles.map(r => [r.RoleCode, r.RoleName]));
    const approverRoleMap = new Map(approverRoles.map(r => [r.RoleCode, r.RoleName]));

    // Enrich each record
    for (const record of data) {
      if (record.businessUserRole) {
        record.businessUserRoleRef = {
          RoleCode: record.businessUserRole,
          RoleName: businessRoleMap.get(record.businessUserRole) || record.businessUserRole
        };
      }
      if (record.approverPartyRole) {
        record.approverPartyRoleRef = {
          RoleCode: record.approverPartyRole,
          RoleName: approverRoleMap.get(record.approverPartyRole) || record.approverPartyRole
        };
      }
    }
  });

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
        console.log(' sscv2EmployeeSrv triggered' + sscv2EmployeeSrv);
        const employee = await sscv2EmployeeSrv.getEmployeeByDisplayId(approverEmployeeId);
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

        // Generate UUID if ID is not provided
        const recordId = row.ID?.trim() || cds.utils.uuid();
        
        await tx.run(
          UPSERT.into('DiscountMatrixSrv.DiscountMatrix').entries({
            ID: recordId,
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

        // Clear cache after upload to refresh role data
        businessUserRolesCache = null;
        approverPartyRolesCache = null;

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