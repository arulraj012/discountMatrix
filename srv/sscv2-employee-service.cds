service Sscv2EmployeeService @(path: '/api/sscv2Employee') {

  function getCurrentEmployee()               returns {
    ID          : String;
    employeeId  : String;
    email       : String;
    displayName : String;
  };

  function getEmployeeByDisplayId(id: String) returns {
    ID          : String;
    employeeId  : String;
    email       : String;
    displayName : String;
  };


}
