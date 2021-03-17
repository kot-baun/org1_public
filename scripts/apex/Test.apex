Map<String, sObject> mapName = new Map<String, sObject>();

mapName.put('ID', new Vehicle__c());
mapName.put('ososo', null);
mapName.put('kfdbkjfn', (sObject) '');
mapName.put(null, null);
mapName.put(null, 'sdfsdfsdfsgs');

for (String s : mapName.values()) {
	System.debug(s);
}
for (String s : mapName.keySet()) {
	System.debug(s);
}
