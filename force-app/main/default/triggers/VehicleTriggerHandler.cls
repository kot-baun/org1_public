public class VehicleTriggerHandler {
	public static void onInsertValidateVehicle(List<Vehicle__c> newList) {
		VehicleTriggerHelper.validateVehicleData(newList);
	}

	public static void onUpdateValidateVehicle(Map<Id, Vehicle__c> oldMap, Map<Id, Vehicle__c> newMap) {
		VehicleTriggerHelper.validateVehicleData(oldMap, newMap);
	}
	public static void nextMaintenanceCreatingHandler() {
		VehicleTriggerHelper.createMaintenanceRecords();
		VehicleTriggerHelper.assignMaintenanceToVehicle();
		VehicleTriggerHelper.prepeareDriversData(VehicleTriggerHelper.MESSAGE_NEW_MAINTENANCE);
		VehicleTriggerHelper.sendMessageToDrivers();
	}
}
