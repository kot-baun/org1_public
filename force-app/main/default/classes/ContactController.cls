public with sharing class ContactController {
	@AuraEnabled(cacheable=true)
	public static List<Contact> getContacts() {
		return [SELECT ID, FirstName, LastName, Email FROM Contact WITH SECURITY_ENFORCED ORDER BY FirstName];
	}
}
