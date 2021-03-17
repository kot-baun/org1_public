@isTest
public with sharing class VehicleTriggerHelper_Test {
	@isTest
	private static void prepeareVehicleData_test1() {
		//Prepare data
		List<Vehicle__c> old = VehicleTriggerHelper_TestDataFactory.createVehicles(
			new List<String>{ 'car' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ -2, -1, 0, 1, 2 },
			new List<Integer>{ -2, -1, 0, 1, 2 },
			null
		);

		for (Vehicle__c vehicle : old) {
			System.debug(vehicle);
		}
	}
}
