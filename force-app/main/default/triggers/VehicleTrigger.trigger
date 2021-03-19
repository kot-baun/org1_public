trigger VehicleTrigger on Vehicle__c(after insert, after update) {
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
	if (Trigger.isAfter) {
		//newMap doesn't exist in insert
		if (Trigger.isInsert) {
			System.debug('point 1');
		} else if (Trigger.isUpdate) {
			VehicleTriggerHandler.updateVehicleProcess(Trigger.old, Trigger.new);
			System.debug('point 1');
		}
	}
}
