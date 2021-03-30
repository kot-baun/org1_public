List<Maintenance__c> resList = [SELECT Id, Maintenance_Vehicle_Descriptions__c FROM Maintenance__c];

for (Maintenance__c value : resList) {
	String s = value.Maintenance_Vehicle_Descriptions__c + '   ' + Approval.isLocked(value.Id);

	if (Approval.isLocked(value.Id)) {
		s += '  unlock is ' + Approval.unlock(value.Id);
	}
	System.debug(s);
}
