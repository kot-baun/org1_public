@isTest
public with sharing class VehicleTriggerHelperTest {
	@TestSetup
	static void makeData() {
		Account acc = DataFactory.generateAccountWithAddress(true);
	}
}
