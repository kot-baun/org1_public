public class VehicleTriggerHandler {
	public static void onInsertValidateVehicle(List<Vehicle__c> newList) {
		VehicleTriggerHelper.validateVehicleDataForMaintenanceProcess(newList);
		VehicleTriggerHelper.validateVehicleDataForStatusNotification(newList);
	}

	public static void onUpdateValidateVehicle(Map<Id, Vehicle__c> oldMap, Map<Id, Vehicle__c> newMap) {
		VehicleTriggerHelper.validateVehicleDataForMaintenanceProcess(oldMap, newMap);
		VehicleTriggerHelper.validateVehicleDataForStatusNotification(oldMap, newMap);
	}
	public static void nextMaintenanceCreatingHandler() {
		//maintenance process
		VehicleTriggerHelper.createMaintenanceRecords();
		VehicleTriggerHelper.assignMaintenanceToVehicle();
		//status notification process

		//combine results and create messages
		VehicleTriggerHelper.mergeMersages();
		VehicleTriggerHelper.sendMessageToDrivers();
	}
}
