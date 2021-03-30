@isTest
public with sharing class VehicleViewControllerTest {
	/**
	 * positive test to check filtering by status
	 * It is expected that four values will be obtained without filtering, and two with it.
	 */
	@isTest
	public static void filteredVehicleRequest_test() {
		//--------------------------     begin data generation     --------------------------
		//prepare data
		List<Vehicle__c> availableTest = VehicleTrigger_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 1, 2 }
		);
		List<Vehicle__c> notAvailableTest = VehicleTrigger_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Not Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 1, 2 }
		);

		List<Vehicle__c> newList = new List<Vehicle__c>();
		newList.addAll(availableTest);
		newList.addAll(notAvailableTest);

		for (Vehicle__c vehicle : newList) {
			vehicle.recalculateFormulas();
		}
		insert newList;
		//--------------------------     end data generation     --------------------------

		//--------------------------   insert test     --------------------------

		Test.startTest();
		List<Vehicle__c> allList = VehicleViewController.getRecords(VehicleViewController.ALL);
		List<Vehicle__c> availableList = VehicleViewController.getRecords(VehicleViewController.AVAILABLE_STATUS);

		System.assertEquals(
			newList.size(),
			allList.size(),
			'Expected to get all records, but difference in number of generated vehicles, in count of ' +
			newList.size() +
			',  and number of requested in VehicleViewController vehicles, in cou   nt of ' +
			allList.size()
		);

		System.assertEquals(
			availableTest.size(),
			availableList.size(),
			'Expected to get available records, but difference in number of generated vehicles, in count of ' +
			availableList.size() +
			',  and number of requested in VehicleViewController vehicles, in cou   nt of ' +
			availableList.size()
		);

		Test.stopTest();
	}

	@isTest
	public static void wiredVehicleRequest() {
		//--------------------------     begin data generation     --------------------------
		//prepare data
		List<Vehicle__c> testVehicleList = VehicleTrigger_TestDataFactory.createVehicles(
			new List<String>{ 'CAR' },
			new List<String>{ 'model_1' },
			new List<String>{ 'TX123' },
			new List<String>{ 'Available' },
			new List<Integer>{ 0 },
			new List<Integer>{ 2 }
		);
		for (Vehicle__c vehicle : testVehicleList) {
			vehicle.recalculateFormulas();
		}
		insert testVehicleList;
		//--------------------------     end data generation     --------------------------

		Test.startTest();
		System.assert(testVehicleList.size() == 1, 'size');
		Vehicle__c testVehicle = testVehicleList.get(0);
		System.debug('test vehicle' + testVehicle);
		List<VehicleViewController.Vehicle> responce = VehicleViewController.getWrappedRecords(
			VehicleViewController.ALL
		);
		System.assert(responce.size() == testVehicleList.size(), 'msg');
		VehicleViewController.Vehicle target = responce.get(0);
		System.debug('target vehicle' + target);
		System.assertEquals(testVehicle.Id, target.id);
		System.assertEquals(testVehicle.Vehicle_model_description__c, target.vehicleDescription);
		System.assertEquals(testVehicle.Vehicle_Status__c, target.status);
		System.assertEquals(testVehicle.Vehicle_plate_number__c, target.plateNumber);
		System.assertEquals(testVehicle.Vehicle_Last_Maintenance_Date__c, target.lastMaintenanceDate);

		Test.stopTest();
	}
}
