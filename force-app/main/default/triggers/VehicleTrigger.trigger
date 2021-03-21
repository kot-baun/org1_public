trigger VehicleTrigger on Vehicle__c(before insert, before update, after insert, after update) {
	// 	before insert,
	// 	before update,
	// 	before delete,
	// 	after insert,
	// 	after update,
	// 	after delete,
	// 	after undelete
	// ) {
	/**
	 * Before insert or update change Last maintenance date value to the previous Next Maintenance date
	 * Or to the TODAY	value, if previous Next Maintenance date does not exist
	 * next, create new Maintenance record
	 */
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			//newMap doesn't exist in insert
			if (BypassContriller.bypassTriger) {
				VehicleTriggerHandler.onInsertValidateVehicle(Trigger.new);
			}
		}
		if (Trigger.isUpdate) {
			if (BypassContriller.bypassTriger) {
				VehicleTriggerHandler.onUpdateValidateVehicle(Trigger.oldMap, Trigger.newMap);
			}
		}
	}

	if (Trigger.isAfter) {
		if (Trigger.isInsert || Trigger.isUpdate) {
			if (BypassContriller.bypassTriger) {
				VehicleTriggerHandler.nextMaintenanceCreatingHandler();
			}
		}
	}
}
