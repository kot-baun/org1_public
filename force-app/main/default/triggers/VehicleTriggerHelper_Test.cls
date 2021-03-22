@isTest
public with sharing class VehicleTriggerHelper_Test {
	/**
	 * test for validate process
	 *
	 * expected, that two valid records will be added to the VehicleTriggerHelper static context, and two invalide will not
	 */
	@isTest
	private static void validateVehicleData_test() {
		//TODO the test covers the insert and update process, but would be bettrer to split it into two different
		//--------------------------     enable bypass     --------------------------
		BypassController.enableBypass();
		//--------------------------     begin data generation     --------------------------
		//prepare data

		//vehicles
		List<Vehicle__c> oldList = VehicleTrigger_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 0, 0, 0, 0 }
		);
		Database.insert(oldList);
		List<Vehicle__c> validList = VehicleTrigger_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 1, 2 }
		);
		List<Vehicle__c> invalidList = VehicleTrigger_TestDataFactory.createVehicles(
			new List<String>{ 'BAD CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ -1, 0 }
		);
		List<Vehicle__c> newList = new List<Vehicle__c>();
		newList.addAll(validList);
		newList.addAll(invalidList);
		for (Vehicle__c vehicle : newList) {
			vehicle.recalculateFormulas();
		}
		Database.insert(newList);

		//careful, dont insert this!! Its exist IN MEMORY ONLY!!!
		for (Integer i = 0; i < oldList.size(); i++) {
			newList.get(i).Id = oldList.get(i).Id;
		}

		// System.debug('--------------------------     after     --------------------------');
		// System.debug('old list size ' + oldList.size());
		// for (Vehicle__c vehicle : oldList) {
		// 	System.debug(vehicle);
		// }
		// System.debug('new list size' + newList.size());
		// for (Vehicle__c vehicle : newList) {
		// 	System.debug(vehicle);
		// }
		// System.debug('-----------------------------------------------------------------------------');

		Map<Id, Vehicle__c> oldMap = new Map<Id, Vehicle__c>();
		for (Vehicle__c v : oldList) {
			oldMap.put(v.Id, v);
		}

		Map<Id, Vehicle__c> newMap = new Map<Id, Vehicle__c>();
		for (Vehicle__c v : newList) {
			newMap.put(v.Id, v);
		}
		//--------------------------     end data generation     --------------------------

		//--------------------------   update test     --------------------------

		Test.startTest();
		VehicleTriggerHelper.validateVehicleDataForMaintenanceProcess(oldMap, newMap);
		for (Vehicle__c vehicle : VehicleTriggerHelper.targetVehicles) {
			System.debug(vehicle);
		}
		System.assertEquals(
			validList.size(),
			VehicleTriggerHelper.targetVehicles.size(),
			'difference between number of valide vehicles, in count of ' +
			validList.size() +
			',  and number of validated in VehicleTriggerHelper vehicles, in count of ' +
			VehicleTriggerHelper.targetVehicles.size()
		);

		Test.stopTest();

		//--------------------------     disable bypass     --------------------------
		BypassController.disableBypass();
	}
	/**
	 *	positive test, check default and custom maintenance creation
	 */
	@isTest
	private static void createMaintenanceRecords_test() {
		//--------------------------     enable bypass     --------------------------
		BypassController.enableBypass();
		//--------------------------     begin data generation     --------------------------
		//two vehicles
		List<Vehicle__c> newVehicleList = VehicleTrigger_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 1, 2 }
		);
		insert newVehicleList;
		//two service, custom and default
		List<Maintenance_Service__c> newMaintenanceServiceList = new List<Maintenance_Service__c>{
			VehicleTrigger_TestDataFactory.createMaintenanceService(1, false),
			VehicleTrigger_TestDataFactory.createMaintenanceService(2, true)
		};
		insert newMaintenanceServiceList;

		//single value, for a custome case
		List<Maintenance__c> newMaintenanceList = VehicleTrigger_TestDataFactory.createMaintemance(
			newMaintenanceServiceList,
			new List<Integer>{ 0 },
			new List<String>{ 'Scheduled' },
			new List<Vehicle__c>{ newVehicleList.get(0) }
		);

		insert newMaintenanceList;
		//first will be with custome maintenance service
		newVehicleList.get(0).Vehicle_Last_Maintenance__c = newMaintenanceList.get(0).Id;
		update newVehicleList;
		//--------------------------     end data generation     --------------------------
		//---------------------     data preset     ---------------------

		VehicleTriggerHelper.targetVehicles = newVehicleList;
		VehicleTriggerHelper.targetMaintenances = new List<Maintenance__c>();
		//---------------------     end data preset     ---------------------

		Test.startTest();
		VehicleTriggerHelper.createMaintenanceRecords();
		Test.stopTest();

		//check, that the onjects was created
		System.assertEquals(2, VehicleTriggerHelper.targetMaintenances.size(), '2 records awaiting');

		Map<Id, Maintenance__c> result = new Map<Id, Maintenance__c>(
			[SELECT Maintenance_Service__c, Maintenance_Service__r.Maintenance_default__c, Name FROM Maintenance__c]
		);

		// for (Maintenance__c maintenance : result.values()) {
		// 	System.debug('maintenance ' + maintenance);
		// 	System.debug('service ' + maintenance.Maintenance_Service__c);
		// 	System.debug('id default ' + maintenance.Maintenance_Service__r.Maintenance_default__c);
		// }
		//custom service
		System.assert(
			result.get(newMaintenanceList.get(0).Id).Maintenance_Service__r.Maintenance_default__c == false,
			'the entry with last maintenance was expected to use the last service'
		);
		result.remove(newMaintenanceList.get(0).Id);

		//default service
		System.assert(
			result.values().get(0).Maintenance_Service__r.Maintenance_default__c == true,
			'the entry without last maintenance was expected to use the default service'
		);
		//--------------------------     disable bypass     --------------------------
		BypassController.disableBypass();
	}
	/**
	 * test for assigning maintenance to a vehicle, defined in maintenance
	 * It is expected, that a record with definition will be assigned, and one without will not be
	 */
	@isTest
	private static void assignMaintenanceToVehicle_test() {
		//--------------------------     enable bypass     --------------------------
		BypassController.enableBypass();
		//--------------------------     begin data generation     --------------------------

		List<Vehicle__c> newVehicleList = VehicleTrigger_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 1, 2 }
		);
		insert newVehicleList;
		List<Maintenance_Service__c> newMaintenanceServiceList = new List<Maintenance_Service__c>{
			VehicleTrigger_TestDataFactory.createMaintenanceService(1, true)
		};
		insert newMaintenanceServiceList;

		List<Maintenance__c> newMaintenanceList = VehicleTrigger_TestDataFactory.createMaintemance(
			newMaintenanceServiceList,
			new List<Integer>{ 0 },
			new List<String>{ 'Scheduled' },
			new List<Vehicle__c>{ newVehicleList.get(0) }
		);
		for (Maintenance__c maintenance : newMaintenanceList) {
			maintenance.recalculateFormulas();
		}
		insert newMaintenanceList;
		//---------------------     end data generation     ---------------------
		//---------------------     data preset     ---------------------
		VehicleTriggerHelper.targetVehicles = newVehicleList;
		VehicleTriggerHelper.targetMaintenances = newMaintenanceList;
		//---------------------     end data preset     ---------------------
		Test.startTest();
		VehicleTriggerHelper.assignMaintenanceToVehicle();
		Test.stopTest();
		//validate, that maintenance with defined Vecinle value will be reflected to this vehicle record
		System.assert(newVehicleList.get(0).Vehicle_Last_Maintenance__c == newMaintenanceList.get(0).Id);

		System.assert(newVehicleList.get(1).Vehicle_Last_Maintenance__c == null);
		//--------------------------     disable bypass     --------------------------
		BypassController.disableBypass();
	}
	/**
	 *
	 */
	@isTest
	private static void prepeareDriversData_test() {
		//--------------------------     enable bypass     --------------------------
		BypassController.enableBypass();
		//--------------------------     begin data generation     --------------------------
		List<Contact> valideContactList = VehicleTrigger_TestDataFactory.createContacts(
			new List<String>{ 'driver_1', 'driver_2' },
			new List<String>{ 'email@test.com', 'email@test.com.ua' }
		);
		List<Contact> invalideContactList = VehicleTrigger_TestDataFactory.createContacts(
			new List<String>{ 'driver_3', 'driver_4' }
		);
		List<Contact> contacts = new List<Contact>();
		contacts.addAll(valideContactList);
		contacts.addAll(invalideContactList);

		insert contacts;

		List<Vehicle__c> vehicleList = VehicleTrigger_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 1, 2 },
			contacts
		);
		for (Vehicle__c vehicle : vehicleList) {
			vehicle.recalculateFormulas();
		}
		insert vehicleList;
		List<Maintenance_Service__c> maintenanceServiceList = new List<Maintenance_Service__c>{
			VehicleTrigger_TestDataFactory.createMaintenanceService(1, false)
		};
		insert maintenanceServiceList;

		List<Maintenance__c> maintenanceList = VehicleTrigger_TestDataFactory.createMaintemance(
			maintenanceServiceList,
			new List<Integer>{ 1 },
			new List<String>{ 'Scheduled' },
			vehicleList
		);
		insert maintenanceList;

		for (Vehicle__c vehicle : vehicleList) {
			for (Maintenance__c maintenance : maintenanceList) {
				if (maintenance.Vehicle__c == vehicle.Id) {
					vehicle.Vehicle_Last_Maintenance__c = maintenance.Id;
				}
			}
		}
		update vehicleList;

		//--------------------------     end data generation     --------------------------
		//---------------------     data preset     ---------------------
		vehicleList = [
			SELECT
				Id,
				Vehicle_Manufacturer__c,
				Vehicle_model__c,
				Vehicle_plate_number__c,
				Vehicle_driver__r.Email,
				Vehicle_driver__r.Name,
				Vehicle_Last_Maintenance__r.Maintenance_due_date__c,
				Vehicle_Last_Maintenance__r.Maintenance_from_date__c
			FROM Vehicle__c
		];
		VehicleTriggerHelper.targetVehicles = vehicleList;
		VehicleTriggerHelper.targetDrivers = new Map<Contact, String>();
		//---------------------     end data preset     ---------------------

		Test.startTest();
		VehicleTriggerHelper.prepeareDriversData(vehicleList, VehicleTriggerHelper.MESSAGE_NEW_MAINTENANCE);
		Test.stopTest();
		System.assert(VehicleTriggerHelper.targetDrivers.size() == valideContactList.size());
		//--------------------------     disable bypass     --------------------------
		BypassController.disableBypass();
	}
	/**
	 *
	 */
	@isTest
	public static void sendMessageToDrivers_test() {
		//--------------------------     enable bypass     --------------------------
		BypassController.enableBypass();
		//--------------------------     begin data generation     --------------------------
		List<Contact> driverContactList = VehicleTrigger_TestDataFactory.createContacts(
			new List<String>{ 'driver_1', 'driver_2' },
			new List<String>{ 'email@test.com', 'email@test.com.ua' }
		);

		insert driverContactList;

		Map<Contact, String> driverMessageMap = new Map<Contact, String>();
		for (Integer i = 0; i < driverContactList.size(); i++) {
			String msg = String.format(
				VehicleTriggerHelper.MESSAGE_NEW_MAINTENANCE_BODY,
				new List<Object>{ 'TX_plate_' + i, Date.today() + i, Date.today() + i + 14 }
			);
			driverMessageMap.put(driverContactList.get(i), msg);
		}
		//--------------------------     end data generation     --------------------------
		//---------------------     data preset     ---------------------
		VehicleTriggerHelper.targetDrivers = driverMessageMap;
		//---------------------     end data preset     ---------------------
		Test.StartTest();
		List<Messaging.SendEmailResult> result = VehicleTriggerHelper.sendMessageToDrivers();
		Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();
		//invocations are equals to 1, if task to send email was created
		System.assertEquals(1, invocations, 'An email has not been sent');
		System.assert(null != result, 'the attempt to send messages was');
		System.assert(result.size() == driverMessageMap.size(), 'all messages have been sent');
		Integer successCount = 0;
		for (Messaging.SendEmailResult res : result) {
			if (res.isSuccess()) {
				successCount++;
			}
		}
		System.assert(successCount == driverMessageMap.size(), 'all messages were sent successfully');
		//--------------------------     disable bypass     --------------------------
		BypassController.disableBypass();
	}
}
