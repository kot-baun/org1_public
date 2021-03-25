public class VehicleTrigger_Test_Helper {
	//defined number of generated records
	static final Integer NUMBER_OF_DRIVERS_WITH_EMAIL = 100;
	static final Integer NUMBER_OF_DRIVERS_WITHOUT_EMAIL = 100;

	static final Integer NUMBER_OF_VALID_RECORDS_WITH_LAST_MAINTENANCE_WITHOUT_DRIVER = 100;
	static final Integer NUMBER_OF_VALID_RECORDS_WITH_LAST_MAINTENANCE_WITH_DRIVER_WITH_EMAIL = NUMBER_OF_DRIVERS_WITH_EMAIL;
	static final Integer NUMBER_OF_VALID_RECORDS_WITH_LAST_MAINTENANCE_WITH_DRIVER_WITHOUT_EMAIL = NUMBER_OF_DRIVERS_WITHOUT_EMAIL;
	static final Integer NUMBER_OF_VALID_RECORDS_WITHOUT_LAST_MAINTENANCE_WITHOUT_DRIVER = 100;

	public static final Integer NUMBER_OF_VALID_RECORDS = 400;
	public static final Integer NUMBER_OF_MESSAGES = 100;
	/**
	 * helper method to do many records
	 */
	public static void makeManyVehicles() {
		//contacts
		//every contact will get message about two vehicles
		List<Contact> driverWithEmail = VehicleTrigger_TestDataFactory.createContacts(
			VehicleTrigger_TestDataFactory.createContactsNames('driverWithEmail', NUMBER_OF_DRIVERS_WITH_EMAIL),
			new List<String>{ 'email@test.com' }
		);
		insert driverWithEmail;
		List<Contact> driverWithoutEmail = VehicleTrigger_TestDataFactory.createContacts(
			VehicleTrigger_TestDataFactory.createContactsNames('driverWithoutEmail', NUMBER_OF_DRIVERS_WITHOUT_EMAIL)
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
	/**
	 * helper method to do one records
	 */
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
}
