public class VehicleTriggerHandler {
	public static void updateVehicleProcess(Map<Id, Vehicle__c> oldMap, Map<Id, Vehicle__c> newMap) {
		VehicleTriggerHelper.prepeareVehicleData(oldMap, newMap);
		VehicleTriggerHelper.createMaintenanceRecords();
		VehicleTriggerHelper.saveMaintenanceRecords();
		VehicleTriggerHelper.saveTargetVehicleRecords();
		VehicleTriggerHelper.prepeareDriversData(VehicleTriggerHelper.MESSAGE_NEW_MAINTENANCE);
		VehicleTriggerHelper.sendMessageToDrivers();
	}
}
