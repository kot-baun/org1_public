// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

Vehicle__c v = new Vehicle__c();
v.Vehicle_plate_number__c = 'TX132';
v.Vehicle_Manufacturer__c = 'FORD';
v.Vehicle_model__c = 's1';
v.Vehicle_Status__c = 'Available';
v.Vehicle_Next_Maintenance_Date__c = Date.today();
System.debug('begin');

System.debug(v);
System.debug('end');

insert v;

System.debug(v);

Maintenance__c maintenance = new Maintenance__c();
maintenance.Maintenance_date__c = Date.today();
maintenance.Maintenance_from_date__c = Date.today();

Maintenance_Service__c defaultServiecs = [
	SELECT Id, Name
	FROM Maintenance_Service__c
	WHERE Maintenance_default__c = TRUE
	LIMIT 1
];

// Schema.DescribeFieldResult F = Maintenance__c.Maintenance_status__c.getDescribe();
// List<Schema.PicklistEntry> P = F.getPicklistValues();

// for (Schema.PicklistEntry variable : P) {
// 	System.debug(variable);
// }

maintenance.Maintenance_Service__c = defaultServiecs.Id;
maintenance.Maintenance_status__c = 'Scheduled';
maintenance.Vehicle__c = v.Id;
v.Vehicle_Last_Maintenance__c = maintenance.Id;

System.debug('---------------------------------   1   ---------------------------------------');
System.debug(maintenance);
System.debug(v);
System.debug('---------------------------------   1   ---------------------------------------');

insert maintenance;

System.debug('---------------------------------   2   ---------------------------------------');
System.debug(maintenance);
System.debug(v);
System.debug('---------------------------------   2   ---------------------------------------');

v.Vehicle_Last_Maintenance__c = maintenance.Id;
insert v;

System.debug('---------------------------------   3   ---------------------------------------');
System.debug(maintenance);
System.debug(v);
System.debug('---------------------------------   3   ---------------------------------------');
