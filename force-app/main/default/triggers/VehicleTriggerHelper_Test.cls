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
	private static void assignMaintenanceToVehicleAndSave() {
		List<Vehicle__c> newVehicleList = VehicleTriggerHelper_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 1, 2 }
		);
		insert newVehicleList;
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
		insert newMaintenanceList;

		//---------------------     end data generation     ---------------------
		//---------------------     data preset     ---------------------

		VehicleTriggerHelper.targetVehicles = newVehicleMap;
		VehicleTriggerHelper.targetMaintenances = newMaintenanceList;
		//---------------------     end data preset     ---------------------

		VehicleTriggerHelper.assignMaintenanceToVehicleAndSave();
		//validate, that maintenance with defined Vecinle value will be reflected to the vehicle record
		System.assert(newVehicleList.get(0).Vehicle_Last_Maintenance__c == newMaintenanceList.get(0).Id);

		System.assert(newVehicleList.get(1).Vehicle_Last_Maintenance__c == null);
	}

	@isTest
	private static void prepeareDriversData_test() {
		List<Contact> valideContactList = VehicleTriggerHelper_TestDataFactory.createContacts(
			new List<String>{ 'driver_1', 'driver_2' },
			new List<String>{ 'email@com', 'email@com.ua' }
		);
		List<Contact> invalideContactList = VehicleTriggerHelper_TestDataFactory.createContacts(
			new List<String>{ 'driver_3', 'driver_4' }
		);
		List<Contact> contacts = new List<Contact>(valideContactList.size() + invalideContactList.size());
		contacts.addAll(valideContactList);
		contacts.addAll(invalideContactList);
		List<Vehicle__c> valideVehicleList = VehicleTriggerHelper_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 1, 2 },
			contacts
		);
	}
}
