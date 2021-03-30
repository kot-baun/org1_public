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

	@AuraEnabled(cacheable=true)
	public static List<Maintenance> getWrappedRecords(Id targetVehicleId) {
		try {
			List<Maintenance__c> maintenances = getRecords(targetVehicleId);
			List<Maintenance> result = new List<Maintenance>();
			for (Maintenance__c value : maintenances) {
				Maintenance target = new Maintenance();
				target.id = value.Id;
				target.fromDate = value.Maintenance_from_date__c;
				target.actualDate = value.Maintenance_date__c;
				target.service = value.Maintenance_Service__r.Name;
				target.status = value.Maintenance_status__c;
				result.add(target);
			}

			return result;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class Maintenance {
		@AuraEnabled
		public Id id;
		@AuraEnabled
		public Date fromDate;
		@AuraEnabled
		public Date actualDate;
		@AuraEnabled
		public String service;
		@AuraEnabled
		public String status;
	}
}
