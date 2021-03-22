@isTest
public with sharing class VehicleTrigger_Test {
	static final Integer numderOfDriverWithEmail = 100;
	static final Integer numderOfDriverWithoutEmail = 100;

	static final Integer numberOfValidRecords_WithLastMaintenance_WithoutDriver = 100;
	static final Integer numberOfValidRecords_WithLastMaintenance_WithDriver_WithEmail = numderOfDriverWithEmail;
	static final Integer numberOfValidRecords_WithLastMaintenance_WithDriver_WithoutEmail = numderOfDriverWithoutEmail;
	static final Integer numberOfValidRecords_WithoutLastMaintenance_WithoutDriver = 100;

	static final Integer numberOfValidRecords = 400;
	static final Integer numberOfMessages = 100;

	static void makeManyVehicles() {
		//contacts
		//every contact will get message about two vehicles
		List<Contact> driverWithEmail = VehicleTrigger_TestDataFactory.createContacts(
			VehicleTrigger_TestDataFactory.createContactsNames('driverWithEmail', numderOfDriverWithEmail),
			new List<String>{ 'email@test.com' }
		);
		insert driverWithEmail;
		List<Contact> driverWithoutEmail = VehicleTrigger_TestDataFactory.createContacts(
			VehicleTrigger_TestDataFactory.createContactsNames('driverWithoutEmail', numderOfDriverWithoutEmail)
		);
		insert driverWithoutEmail;
		//vehicles
		List<Vehicle__c> vehicleWithLastMaintenanceList = new List<Vehicle__c>();
		vehicleWithLastMaintenanceList.addAll(createVehicles(null));
		vehicleWithLastMaintenanceList.addAll(createVehicles(driverWithEmail));
		vehicleWithLastMaintenanceList.addAll(createVehicles(driverWithoutEmail));
		System.debug('vehicleWithLastMaintenanceList size ' + vehicleWithLastMaintenanceList.size());
		insert vehicleWithLastMaintenanceList;
		List<Vehicle__c> vehicleWithoutLastMaintenanceList = createVehicles(null);
		System.debug('vehicleWithoutLastMaintenanceList size ' + vehicleWithoutLastMaintenanceList.size());
		insert vehicleWithoutLastMaintenanceList;

		//maintenance service, firsat wiill be default service, secont is usual
		List<Maintenance_Service__c> maintenanceServiceList = VehicleTrigger_TestDataFactory.createMaintenanceService(
			2,
			1
		);

		insert maintenanceServiceList;
		//maintenance
		List<Maintenance__c> maintenanceList = VehicleTrigger_TestDataFactory.createMaintemance(
			new List<Maintenance_Service__c>{ maintenanceServiceList.get(1) },
			new List<Integer>{ 1 },
			new List<String>{ 'Scheduled' },
			vehicleWithLastMaintenanceList
		);
		System.debug('maintenanceList size ' + maintenanceList.size());
		insert maintenanceList;

		for (Vehicle__c vehicle : vehicleWithLastMaintenanceList) {
			for (Maintenance__c maintenance : maintenanceList) {
				if (maintenance.Vehicle__c == vehicle.Id) {
					vehicle.Vehicle_Last_Maintenance__c = maintenance.Id;
				}
			}
		}
		System.debug('vehicleWithLastMaintenanceList size (before update)' + vehicleWithLastMaintenanceList.size());

		update vehicleWithLastMaintenanceList;
	}

	static List<Vehicle__c> createVehicles(List<Contact> drivers) {
		if (drivers != null) {
			return VehicleTrigger_TestDataFactory.createVehicles(
				new List<String>{ 'CAR' },
				new List<String>{ 'model_1' },
				new List<String>{ 'TX123' },
				new List<String>{ 'Available' },
				new List<Integer>{ 0 },
				new List<Integer>{ 2 },
				drivers
			);
		} else {
			return VehicleTrigger_TestDataFactory.createVehicles(
				new List<String>{ 'CAR' },
				VehicleTrigger_TestDataFactory.createContactsNames('model', 100),
				new List<String>{ 'TX123' },
				new List<String>{ 'Available' },
				new List<Integer>{ 0 },
				new List<Integer>{ 2 }
			);
		}
	}

	public static Vehicle__c makeSingleVehicle(Boolean withDriver, Boolean withMaintenance) {
		Contact driver;
		Maintenance__c maintenance;

		if (withDriver) {
			driver = new Contact();
			driver.LastName = 'testDriver';
			driver.Email = 'kamkaliev@gmail.com';
			insert driver;
		}
		//default service
		List<Maintenance_Service__c> serviceList = VehicleTrigger_TestDataFactory.createMaintenanceService(1, 1);
		insert serviceList;
		Vehicle__c vehicle = new Vehicle__c();
		vehicle.Vehicle_Manufacturer__c = 'testCar';
		vehicle.Vehicle_model__c = 'model1';
		vehicle.Vehicle_plate_number__c = 'TX456';
		vehicle.Vehicle_Status__c = 'Available';
		vehicle.Vehicle_Last_Maintenance_Date__c = Date.today();
		vehicle.Vehicle_Next_Maintenance_Date__c = Date.today() + 7;
		vehicle.Vehicle_driver__c = driver.Id;
		// insert vehicle;
		vehicle.recalculateFormulas();
		insert vehicle;

		if (withMaintenance) {
			maintenance = new Maintenance__c();
			maintenance.Maintenance_Service__c = serviceList.get(0).Id;
			maintenance.Maintenance_from_date__c = Date.today() + 7;
			maintenance.Maintenance_status__c = 'Scheduled';
			maintenance.Vehicle__c = vehicle.Id;
			maintenance.recalculateFormulas();
			insert maintenance;
			vehicle.Vehicle_Last_Maintenance__c = maintenance.Id;
			update vehicle;
		}
		return vehicle;
	}

	@isTest
	private static void single_test() {
		makeSingleVehicle(true, false);
		List<Vehicle__c> resultVehicles = [SELECT Id, Vehicle_Next_Maintenance_Date__c FROM Vehicle__c];
		//check, that the record was created
		System.assert(resultVehicles.size() == 1);
		List<Maintenance__c> resultMaintenance = [SELECT Id, Maintenance_from_date__c, Vehicle__c FROM Maintenance__c];

		System.debug('vehicles ' + resultVehicles.size() + 'maintenance ' + resultMaintenance.size());
		for (Maintenance__c maintenance : resultMaintenance) {
			System.debug(maintenance);
		}
		//check, that the record was created
		System.assert(resultMaintenance.size() == 1);
		//check, that this is related records
		System.assert(resultVehicles.get(0).Id == resultMaintenance.get(0).Vehicle__c);
		System.assert(
			resultVehicles.get(0).Vehicle_Next_Maintenance_Date__c == resultMaintenance.get(0).Maintenance_from_date__c
		);
	}

	@isTest
	private static void bulk_test() {
		makeManyVehicles();

		Map<Id, Vehicle__c> vehiclesMap = new Map<Id, Vehicle__c>(
			[
				SELECT
					Id,
					Vehicle_Last_Maintenance_Date__c,
					Vehicle_Next_Maintenance_Date__c,
					Vehicle_Last_Maintenance__c
				FROM Vehicle__c
			]
		);
		System.debug('in test vehiclesMap size ' + vehiclesMap.size());
		System.assert(vehiclesMap.size() == numberOfValidRecords);
		List<Maintenance__c> maintenanceList = [SELECT Id FROM Maintenance__c];
		System.debug('in test maintenanceList size ' + maintenanceList.size());
	}
}
