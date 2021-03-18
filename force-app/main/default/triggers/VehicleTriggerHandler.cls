public class VehicleTriggerHandler {
	public static void updateVehicleProcess(List<Vehicle__c> oldList, List<Vehicle__c> newList) {
		// VehicleTriggerHelper.prepeareVehicleData(oldList, newList);
		// VehicleTriggerHelper.createMaintenanceRecords();

		VehicleTriggerHelper.assignMaintenanceToVehicleAndSave();
		// VehicleTriggerHelper.prepeareDriversData(VehicleTriggerHelper.MESSAGE_NEW_MAINTENANCE);
		// VehicleTriggerHelper.sendMessageToDrivers();
	}
}
