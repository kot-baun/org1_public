public static void print() {
	System.debug('hello');
}

public static List<sObject> setField(String name, String field, List<sObject> result, List<String> manufacture) {
	List<sObject> tmpResult = new List<sObject>();
	if (result.size() == 0) {
		for (String parameter : manufacture) {
			Schema.SObjectType type = Schema.getGlobalDescribe().get(name);
			sObject vehicle = type.newSObject();
			vehicle.put(field, parameter);
			System.debug(vehicle);
			tmpResult.add(vehicle);
		}
	} else {
		for (sObject oldVehicle : result) {
			for (String parameter : manufacture) {
				sObject vehicle = oldVehicle.clone();
				vehicle.put(field, parameter);
				System.debug(vehicle);
				tmpResult.add(vehicle);
			}
		}
	}
	return tmpResult;
}

List<Vehicle__c> result = new List<Vehicle__c>();
List<Date> manufacture = new List<Date>();
manufacture.add(Date.today() + 4);
manufacture.add(Date.today() + 1);
manufacture.add(Date.today() + -2);

result = setField('Vehicle__c', 'Vehicle_Manufacturer__c', result, manufacture);
print();
System.debug('------------------------------------------------------------------');

for (Vehicle__c v : result) {
	System.debug(v);
}
System.debug('------------------------------------------------------------------');
