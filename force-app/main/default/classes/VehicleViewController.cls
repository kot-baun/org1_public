public with sharing class VehicleViewController {
	private static final String ALL = 'All';
	private static final String NOT_AVAILABLE_STATUS = 'Not Available';
	private static final String AT_SERVICE_STATUS = 'At Service';
	private static final String AVAILABLE_STATUS = 'Available';

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

	@AuraEnabled(cacheable=true)
	public static List<Vehicle> getWrappedRecords(String status) {
		List<Vehicle> vehicles = new List<Vehicle>();
		List<Vehicle__c> vehiclesData = getRecords(status);

		for (Vehicle__c vehicleData : vehiclesData) {
			Vehicle vehicle = new Vehicle();

			vehicle.id = vehicleData.Id;
			vehicle.vehicleDescription = vehicleData.Vehicle_model_description__c;
			vehicle.plateNumber = vehicleData.Vehicle_plate_number__c;
			vehicle.driverName = vehicleData.Vehicle_driver__r.Name;
			vehicle.driverContact = vehicleData.Vehicle_driver_contact_phone_reader__c;
			vehicle.status = vehicleData.Vehicle_Status__c;
			vehicle.type = vehicleData.Vehicle_Type__c;
			vehicle.lastMaintenanceDate = vehicleData.Vehicle_Last_Maintenance_Date__c;

			vehicles.add(vehicle);
		}

		return vehicles;
	}

	public class Vehicle {
		@AuraEnabled
		public Id id;
		@AuraEnabled
		public String vehicleDescription;
		@AuraEnabled
		public String plateNumber;
		@AuraEnabled
		public String driverName;
		@AuraEnabled
		public String driverContact;
		@AuraEnabled
		public String status;
		@AuraEnabled
		public String type;
		@AuraEnabled
		public Date lastMaintenanceDate;
	}
}
