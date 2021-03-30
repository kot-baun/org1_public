public with sharing class VehicleViewController {
	private static final String ALL = 'All';
	private static final String NOT_AVAILABLE_STATUS = 'Not Available';
	private static final String AT_SERVICE_STATUS = 'At Service';
	private static final String AVAILABLE_STATUS = 'Available';

	@AuraEnabled(cacheable=true)
	public static List<Vehicle__c> getRecords(String status) {
		if (status != ALL) {
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
				WHERE Vehicle_Status__c = :status
				WITH SECURITY_ENFORCED
			];
		}
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
