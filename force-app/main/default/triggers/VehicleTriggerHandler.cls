public class VehicleTriggerHandler {
	public static void onNextMaintenanceUpdate(Map<Id, Vehicle__c> oldMap, Map<Id, Vehicle__c> newMap) {
		VehicleTriggerHelper.validateVehicleData(oldMap, newMap);
		VehicleTriggerHelper.createMaintenanceRecords();
		VehicleTriggerHelper.assignMaintenanceToVehicleAndSave();
		VehicleTriggerHelper.assignMaintenanceToVehicleAndSave();
		VehicleTriggerHelper.prepeareDriversData(VehicleTriggerHelper.MESSAGE_NEW_MAINTENANCE);
		VehicleTriggerHelper.sendMessageToDrivers();
	}

	public static void insertVehicleProcess(Map<Id, Vehicle__c> newMap) {
		VehicleTriggerHelper.validateVehicleData(newMap);
		VehicleTriggerHelper.createMaintenanceRecords();
		VehicleTriggerHelper.assignMaintenanceToVehicleAndSave();
		VehicleTriggerHelper.assignMaintenanceToVehicleAndSave();
		VehicleTriggerHelper.prepeareDriversData(VehicleTriggerHelper.MESSAGE_NEW_MAINTENANCE);
		VehicleTriggerHelper.sendMessageToDrivers();
	}
}
