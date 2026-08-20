const cds = require('@sap/cds')

function toExternalEmployee(data) {
	return {
		ID: data.id,
		employeeId: data.id ?? "NA",
		email: data.workplaceAddress?.eMail ?? "NA",
		displayId: data.employeeDisplayId,
		displayName: data.formattedName ?? "NA"
	};
}

function toEmployee(data) {
	return {
		ID: data.id,
		updatedOn: data.adminData.updatedOn,
		formattedName: data.formattedName ?? null		
	};
}

class Sscv2EmployeeService extends cds.ApplicationService {
	init() {
		this.on('getCurrentEmployee', async (req) => {
			try {
				const currentEmail = req?.user?.id;
				const employeesApi = await cds.connect.to("Employee.Service");
				const currentEmployeeData = await employeesApi.send("GET", `/employees?$filter=workplaceAddress/eMail eq '${currentEmail}'`);
				if (currentEmployeeData && currentEmployeeData.value && currentEmployeeData.value[0]) {
					return toExternalEmployee(currentEmployeeData.value[0]);
				}
				return req.reject(400, "Employee not found.");
			} catch (err) {
				return req.reject(err);
			}
		});

		this.on('getEmployeeByDisplayId', async (req) => {
			try {
				const displayId = req?.data?.id;
				console.log("Discount Matrix getEmployeeByDisplayId"+displayId);
				const employeesApi = await cds.connect.to("Employee.Service");
				const employeeData = await employeesApi.send("GET", `/employees?$filter=displayId eq '${displayId}'`);
				if (employeeData && employeeData.value && employeeData.value[0]) {
					return toExternalEmployee(employeeData.value[0]);
				}
				return req.reject(400, "Approver Employee not found.");
			} catch (err) {
				return req.reject(err);
			}
		});

		return super.init();
	}
}

module.exports = { Sscv2EmployeeService }