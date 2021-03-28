public with sharing class MaintenanceViewController {
	@AuraEnabled(cacheable=true)
	public static List<Maintenance__c> getRecords(Id targetVehicleId) {
		return [
			SELECT Id, Maintenance_from_date__c, Maintenance_date__c, Maintenance_Service__r.Name, Maintenance_status__c
			FROM Maintenance__c
			WHERE Maintenance__c.Vehicle__c = :targetVehicleId
			WITH SECURITY_ENFORCED
		];
	}
}
