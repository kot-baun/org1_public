public with sharing class VehicleViewController {
	@AuraEnabled(cacheable=true)
	public static List<Vehicle__c> getRecords() {
		// return [
		// 	SELECT Id, Vehicle_model_description__c, Vehicle_plate_number__c
		// 	FROM Vehicle__c
		// 	WITH SECURITY_ENFORCED
		// ];
		return [
			SELECT
				Id,
				Vehicle_model_description__c,
				Vehicle_plate_number__c,
				Vehicle_driver__r.Name,
				Vehicle_driver_contact_phone_reader__c,
				Vehicle_Status__c,
				Vehicle_Type__c,
				Vehicle_Last_Maintenance_Date__c
			FROM Vehicle__c
			WITH SECURITY_ENFORCED
		];
	}
}
