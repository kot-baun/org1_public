@isTest
public with sharing class VehicleTriggerHelper_Test {
	@isTest
	private static void prepeareVehicleData_test() {
		//Prepare data
		List<Vehicle__c> oldList = VehicleTriggerHelper_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 0, 0, 0, 0 }
		);
		Database.insert(oldList);
		System.debug('-----------------------------------------------------------------------------');
		System.debug('old list size ' + oldList.size());
		for (Vehicle__c vehicle : oldList) {
			System.debug(vehicle);
		}
		List<Vehicle__c> newList = VehicleTriggerHelper_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ -1, 0, 1, 2 }
		);

		Database.insert(newList);
		System.debug('new list size' + newList.size());
		for (Vehicle__c vehicle : newList) {
			System.debug(vehicle);
		}
		System.debug('-----------------------------------------------------------------------------');

		for (Integer i = 0; i < oldList.size(); i++) {
			newList.get(i).Id = oldList.get(i).Id;
		}

		System.debug('--------------------     after     ------------------------------------');
		System.debug('old list size ' + oldList.size());
		for (Vehicle__c vehicle : oldList) {
			System.debug(vehicle);
		}
		System.debug('new list size' + newList.size());
		for (Vehicle__c vehicle : newList) {
			System.debug(vehicle);
		}
		System.debug('-----------------------------------------------------------------------------');

		Map<Id, Vehicle__c> oldMap = new Map<Id, Vehicle__c>();
		for (Vehicle__c v : oldList) {
			oldMap.put(v.Id, v);
		}

		Map<Id, Vehicle__c> newMap = new Map<Id, Vehicle__c>();
		for (Vehicle__c v : newList) {
			newMap.put(v.Id, v);
		}

		VehicleTriggerHelper.prepeareVehicleData_2(oldMap, newMap);
		for (Vehicle__c vehicle : VehicleTriggerHelper.targetVehicles.values()) {
			System.debug(vehicle);
		}
		//TODO hardcode
		System.assertEquals(2, VehicleTriggerHelper.targetVehicles.size());
	}
	/**
	 *	positive test, check default and custom maintenance creation
	 */
	@isTest
	private static void createMaintenanceRecords_test() {
		//prepare data
		//two vehicles
		List<Vehicle__c> newVehicleList = VehicleTriggerHelper_TestDataFactory.createVehicles(
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
			VehicleTriggerHelper_TestDataFactory.createMaintenanceService(1, false),
			VehicleTriggerHelper_TestDataFactory.createMaintenanceService(2, true)
		};
		insert newMaintenanceServiceList;
		for (Maintenance_Service__c service : newMaintenanceServiceList) {
			System.debug('maintenance service ' + +service);
		}

		//single value, for a custome case
		List<Maintenance__c> newMaintenanceList = VehicleTriggerHelper_TestDataFactory.createMaintemance(
			newMaintenanceServiceList,
			new List<Integer>{ 0 },
			new List<String>{ 'Scheduled' },
			new List<Vehicle__c>{ newVehicleList.get(0) }
		);

		insert newMaintenanceList;
		//first will be with custome maintenance service
		newVehicleList.get(0).Vehicle_Last_Maintenance__c = newMaintenanceList.get(0).Id;
		update newVehicleList;

		Map<Id, Vehicle__c> newVehicleMap = new Map<Id, Vehicle__c>();
		for (Vehicle__c v : newVehicleList) {
			newVehicleMap.put(v.Id, v);
		}
		VehicleTriggerHelper.targetVehicles = newVehicleMap;
		System.debug('vehicle');
		for (Vehicle__c vehicle : newVehicleList) {
			System.debug(vehicle);
			System.debug(vehicle.Vehicle_Last_Maintenance__c);
		}
		System.debug('custome maintenance');
		System.debug(newMaintenanceList.get(0));

		VehicleTriggerHelper.createMaintenanceRecords();
		//check, that the onjects was created
		System.assertEquals(2, VehicleTriggerHelper.targetMaintenances.size(), '2 records awaiting');

		Map<Id, Maintenance__c> result = new Map<Id, Maintenance__c>(
			[SELECT Maintenance_Service__c, Maintenance_Service__r.Maintenance_default__c, Name FROM Maintenance__c]
		);

		for (Maintenance__c maintenance : result.values()) {
			System.debug('maintenance ' + maintenance);
			System.debug('service ' + maintenance.Maintenance_Service__c);
			System.debug('id default ' + maintenance.Maintenance_Service__r.Maintenance_default__c);
		}
		//TODO hardcode
		//custom service
		System.assert(result.get(newMaintenanceList.get(0).Id).Maintenance_Service__r.Maintenance_default__c == false);
		result.remove(newMaintenanceList.get(0).Id);

		//default service
		System.assert(result.values().get(0).Maintenance_Service__r.Maintenance_default__c == true);
	}
	/**
	 *
	 */
	@isTest
	private static void assignMaintenanceToVehicleAndSave_test() {
		List<Vehicle__c> newVehicleList = VehicleTriggerHelper_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 12 }
		);
		insert newVehicleList;
		// Map<Id, Vehicle__c> newVehicleMap = new Map<Id, Vehicle__c>(
		// 	[SELECT ID, Vehicle_Last_Maintenance__c FROM Vehicle__c]
		// );
		Map<Id, Vehicle__c> newVehicleMap = new Map<Id, Vehicle__c>();
		for (Vehicle__c v : newVehicleList) {
			newVehicleMap.put(v.Id, v);
		}
		List<Maintenance_Service__c> newMaintenanceServiceList = new List<Maintenance_Service__c>{
			VehicleTriggerHelper_TestDataFactory.createMaintenanceService(1, false)
		};
		insert newMaintenanceServiceList;

		List<Maintenance__c> newMaintenanceList = VehicleTriggerHelper_TestDataFactory.createMaintemance(
			newMaintenanceServiceList,
			new List<Integer>{ 0 },
			new List<String>{ 'Scheduled' },
			new List<Vehicle__c>{ newVehicleList.get(0) }
		);
		for (Maintenance__c maintenance : newMaintenanceList) {
			maintenance.recalculateFormulas();
		}
		insert newMaintenanceList;

		// for (Vehicle__c vehicle : newVehicleMap.values()) {
		// 	for (Maintenance__c maintenance : newMaintenanceList) {
		// 		if (maintenance.Vehicle__c == vehicle.Id) {
		// 			System.debug('wow');
		// 			vehicle.Vehicle_Last_Maintenance__c = maintenance.Id;
		// 		}
		// 	}
		// }

		// System.debug(newVehicleList.get(0));
		// update newVehicleList;

		//---------------------     end data generation     ---------------------
		//---------------------     data preset     ---------------------

		VehicleTriggerHelper.targetVehicles = newVehicleMap;
		VehicleTriggerHelper.targetMaintenances = newMaintenanceList;
		//---------------------     end data preset     ---------------------

		VehicleTriggerHelper.assignMaintenanceToVehicleAndSave();
		//validate, that maintenance with defined Vecinle value will be reflected to this vehicle record
		// System.assert(newVehicleList.get(0).Vehicle_Last_Maintenance__c == newMaintenanceList.get(0).Id);

		// System.assert(newVehicleList.get(1).Vehicle_Last_Maintenance__c == null);
	}

	@isTest
	private static void prepeareDriversData_test() {
		//--------------------------     begin data generation     --------------------------
		List<Contact> valideContactList = VehicleTriggerHelper_TestDataFactory.createContacts(
			new List<String>{ 'driver_1', 'driver_2' },
			new List<String>{ 'email@test.com', 'email@test.com.ua' }
		);
		System.debug('valid contact list size ' + valideContactList.size());
		List<Contact> invalideContactList = VehicleTriggerHelper_TestDataFactory.createContacts(
			new List<String>{ 'driver_3', 'driver_4' }
		);
		System.debug('invalid contact list size ' + invalideContactList.size());

		List<Contact> contacts = new List<Contact>();
		contacts.addAll(valideContactList);
		contacts.addAll(invalideContactList);
		// System.debug('---------------------------------------------------------------');
		// for (Contact contact : contacts) {
		// 	System.debug(contact);
		// }
		insert contacts;

		for (Contact contact : contacts) {
			System.debug(contact);
		}

		List<Vehicle__c> vehicleList = VehicleTriggerHelper_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 1, 2 },
			contacts
		);
		System.debug('vehicle list size ' + vehicleList.size());
		insert vehicleList;
		List<Maintenance_Service__c> maintenanceServiceList = new List<Maintenance_Service__c>{
			VehicleTriggerHelper_TestDataFactory.createMaintenanceService(1, false)
		};
		insert maintenanceServiceList;

		List<Maintenance__c> maintenanceList = VehicleTriggerHelper_TestDataFactory.createMaintemance(
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

		Map<Id, Vehicle__c> vehicleMap = new Map<Id, Vehicle__c>(
			[
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
			]
		);
		VehicleTriggerHelper.targetVehicles = vehicleMap;
		// VehicleTriggerHelper.targetMaintenances = maintenanceList;
		//---------------------     end data preset     ---------------------

		// for (Vehicle__c vehicle : vehicleMap.values()) {
		// 	String str = String.format(
		// 		'vehicle {0}{1} driver name {2} email {3} from date {4} due date{5}',
		// 		new List<Object>{
		// 			vehicle.Vehicle_Manufacturer__c,
		// 			vehicle.Vehicle_model__c,
		// 			vehicle.Vehicle_driver__r.Name,
		// 			vehicle.Vehicle_driver__r.Email,
		// 			vehicle.Vehicle_Last_Maintenance__r.Maintenance_from_date__c,
		// 			vehicle.Vehicle_Last_Maintenance__r.Maintenance_due_date__c
		// 		}
		// 	);
		// 	System.debug(str);
		// }
		// System.debug('--------------------------------');
		VehicleTriggerHelper.prepeareDriversData(VehicleTriggerHelper.MESSAGE_NEW_MAINTENANCE);

		System.debug('vehicle drivers ' + VehicleTriggerHelper.targetDrivers.size());
		System.assert(VehicleTriggerHelper.targetDrivers.size() == valideContactList.size());
	}
	@isTest
	public static void sendMessageToDrivers_test() {
		//--------------------------     begin data generation     --------------------------
		List<Contact> driverContactList = VehicleTriggerHelper_TestDataFactory.createContacts(
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
		for (Messaging.SendEmailResult res : results) {
			if (res.isSuccess()) {
				successCount++;
			}
		}
		System.assert(successCount == driverMessageMap.size(), 'all messages were sent successfully');
	}
}
