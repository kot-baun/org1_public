@isTest
public with sharing class VehicleTriggerHelper_TestDataFactory {
	public static List<Vehicle__c> createVehicles(
		List<String> manufacture,
		List<String> model,
		List<String> plateNumber,
		List<String> status,
		List<Integer> lastDate,
		List<Integer> nextDate
	) {
		List<Vehicle__c> result = new List<Vehicle__c>();

		result = setVehicleField('Vehicle__c', 'Vehicle_Manufacturer__c', result, manufacture);
		result = setVehicleField('Vehicle__c', 'Vehicle_model__c', result, model);
		result = setVehicleField('Vehicle__c', 'Vehicle_plate_number__c', result, plateNumber);
		result = setVehicleField('Vehicle__c', 'Vehicle_Status__c', result, status);

		List<Date> targetLastDate = new List<Date>();
		for (Integer value : lastDate) {
			targetLastDate.add(Date.today() + value);
		}
		result = setVehicleField('Vehicle__c', 'Vehicle_Last_Maintenance_Date__c', result, targetLastDate);

		List<Date> targetNextDate = new List<Date>();
		for (Integer value : nextDate) {
			targetNextDate.add(Date.today() + value);
		}
		result = setVehicleField('Vehicle__c', 'Vehicle_Next_Maintenance_Date__c', result, targetNextDate);

		return result;
	}

	public static List<Vehicle__c> createVehicles(
		List<String> manufacture,
		List<String> model,
		List<String> plateNumber,
		List<String> status,
		List<Integer> lastDate,
		List<Integer> nextDate,
		List<Contact> contacts
	) {
		List<Vehicle__c> result = createVehicles(manufacture, model, plateNumber, status, lastDate, nextDate);
		result = setVehicleField('Vehicle__c', 'Vehicle_driver__c', result, contacts);
		return result;
	}

	public static List<Maintenance__c> createMaintemance(
		List<Maintenance_Service__c> maintenanceService,
		List<Integer> fromDate,
		List<String> status,
		List<Vehicle__c> vehicle
	) {
		List<Maintenance__c> result = new List<Maintenance__c>();
		result = setVehicleField('Maintenance__c', 'Maintenance_Service__c', result, maintenanceService);

		List<Date> targetLastDate = new List<Date>();
		for (Integer value : fromDate) {
			targetLastDate.add(Date.today() + value);
		}
		result = setVehicleField('Vehicle__c', 'Maintenance_from_date__c', result, targetLastDate);
		result = setVehicleField('Maintenance__c', 'Maintenance_status__c', result, status);
		result = setVehicleField('Maintenance__c', 'Vehicle__c', result, vehicle);
		return result;
	}
	/**
	 * create maintenance service
	 * @param n suffix for adress and name
	 * @param defaultService checkbox, create default service , or not
	 */
	public static Maintenance_Service__c createMaintenanceService(Integer n, Boolean defaultService) {
		Maintenance_Service__c maintenanceService = new Maintenance_Service__c();
		maintenanceService.Address__c = 'Adress ' + n;
		maintenanceService.Maintenance_default__c = Boolean.valueOf('False');
		maintenanceService.Name = 'testMaintenanceService_' + n;
		maintenanceService.Maintenance_default__c = defaultService;
		return maintenanceService;
	}
	/**
	 * builder for Contacts
	 * @param name requared field, name of contact
	 */
	public static List<Contact> createContacts(List<String> name) {
		List<Contact> result = new List<Contact>();
		result = setVehicleField('Contact', 'LastName', result, name);
		return result;
	}
	/**
	 * builder for Contacts
	 * @param name requared field, name of contact
	 * @param email email field. Caution, no validation!!!!!//TODO validation?
	 */
	public static List<Contact> createContacts(List<String> name, List<String> email) {
		List<Contact> result = createContacts(name);
		result = setVehicleField('Contact', 'Email', result, email);
		return result;
	}

	public static List<SObject> setVehicleField(
		String objectName,
		String objectField,
		List<sObject> target,
		List<String> value
	) {
		if (null == value || value.size() == 0) {
			return target;
		}
		// System.debug(
		// 	String.format(
		// 		' object name {0} field {1} target.size = {2} values size = {3}',
		// 		new List<Object>{ objectName, objectField, target.size(), value.size() }
		// 	)
		// );

		List<SObject> tmpResult = new List<sObject>();
		if (target.size() == 0) {
			for (String parameter : value) {
				Schema.SObjectType type = Schema.getGlobalDescribe().get(objectName);
				sObject vehicle = type.newSObject();
				vehicle.put(objectField, parameter);
				tmpResult.add(vehicle);
			}
		} else {
			for (SObject oldVehicle : target) {
				for (String parameter : value) {
					SObject vehicle = oldVehicle.clone();
					vehicle.put(objectField, parameter);
					tmpResult.add(vehicle);
				}
			}
		}
		return tmpResult;
	}

	public static List<SObject> setVehicleField(
		String objectName,
		String objectField,
		List<sObject> target,
		List<Date> value
	) {
		if (null == value || value.size() == 0) {
			return target;
		}
		// System.debug(
		// 	String.format(
		// 		' object name {0} field {1} target.size = {2} values size = {3}',
		// 		new List<Object>{ objectName, objectField, target.size(), value.size() }
		// 	)
		// );
		List<sObject> tmpResult = new List<sObject>();
		if (target.size() == 0) {
			for (Date parameter : value) {
				Schema.SObjectType type = Schema.getGlobalDescribe().get(objectName);
				sObject vehicle = type.newSObject();
				vehicle.put(objectField, (Date) parameter);
				tmpResult.add(vehicle);
			}
		} else {
			for (sObject oldVehicle : target) {
				for (Date parameter : value) {
					sObject vehicle = oldVehicle.clone();
					vehicle.put(objectField, parameter);
					tmpResult.add(vehicle);
				}
			}
		}
		return tmpResult;
	}

	public static List<SObject> setVehicleField(
		String objectName,
		String objectField,
		List<sObject> target,
		List<sObject> value
	) {
		if (null == value || value.size() == 0) {
			return target;
		}
		// System.debug(
		// 	String.format(
		// 		' object name {0} field {1} target.size = {2} values size = {3}',
		// 		new List<Object>{ objectName, objectField, target.size(), value.size() }
		// 	)
		// );
		List<sObject> tmpResult = new List<sObject>();
		if (target.size() == 0) {
			for (sObject parameter : value) {
				Schema.SObjectType type = Schema.getGlobalDescribe().get(objectName);
				sObject vehicle = type.newSObject();
				vehicle.put(objectField, parameter.Id);
				tmpResult.add(vehicle);
			}
		} else {
			for (SObject oldVehicle : target) {
				for (sObject parameter : value) {
					SObject vehicle = oldVehicle.clone();
					vehicle.put(objectField, parameter.Id);
					tmpResult.add(vehicle);
				}
			}
		}
		return tmpResult;
	}
}