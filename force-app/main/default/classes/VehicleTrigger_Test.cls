@isTest
public with sharing class VehicleTrigger_Test {
	/**
	 * complex positive test, to validate single record creation
	 */
	@isTest
	private static void singleVehicleCreation_test() {
		VehicleTrigger_Test_Helper.makeSingleVehicle(true, false);
		List<Vehicle__c> resultVehicles = [SELECT Id, Vehicle_Next_Maintenance_Date__c FROM Vehicle__c];
		//check, that the vehicle record was created
		System.assert(resultVehicles.size() == 1, 'FAIL to create vehicle\n');
		List<Maintenance__c> resultMaintenance = [SELECT Id, Maintenance_from_date__c, Vehicle__c FROM Maintenance__c];

		System.debug('vehicles ' + resultVehicles.size() + 'maintenance ' + resultMaintenance.size());
		for (Maintenance__c maintenance : resultMaintenance) {
			System.debug(maintenance);
		}
		//check, that the record was created
		System.assert(resultMaintenance.size() == 1, 'FAIL to create maintenance\n');
		//check, that this is related records
		System.assert(
			resultVehicles.get(0).Id == resultMaintenance.get(0).Vehicle__c,
			'were created a vehicle and a maintenance records, they shoud be linked, but this does not happens'
		);
		System.assert(
			resultVehicles.get(0).Vehicle_Next_Maintenance_Date__c == resultMaintenance.get(0).Maintenance_from_date__c,
			'mismatch of the date of maintenance indicated in the record for the vehicle and maintenance'
		);
	}
	/**
	 * complex positive test, to validate many record creation
	 */
	@isTest
	private static void manyVehiclesCreation_test() {
		VehicleTrigger_Test_Helper.makeManyVehicles();

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
		System.assert(vehiclesMap.size() == VehicleTrigger_Test_Helper.NUMBER_OF_VALID_RECORDS);
		List<Maintenance__c> maintenanceList = [SELECT Id FROM Maintenance__c];
		System.debug('in test maintenanceList size ' + maintenanceList.size());
	}
}
