@isTest
public with sharing class VehicleTriggerHelper_TestDataFactory {
	public static List<Vehicle__c> createVehicles(
		List<String> manufacture,
		List<String> model,
		List<String> plateNumber,
		List<String> status,
		List<Integer> lastDate,
		List<Integer> nextDate,
		List<Maintenance__c> lastMaintenance
	) {
		List<Vehicle__c> result = new List<Vehicle__c>();

		result = setVehicleField('Vehicle__c', 'Vehicle_Manufacturer__c', result, manufacture);
		result = setVehicleField('Vehicle__c', 'Vehicle_model__c', result, model);
		result = setVehicleField('Vehicle__c', 'Vehicle_plate_number__c', result, plateNumber);
		result = setVehicleField('Vehicle__c', 'Vehicle_Status__c', result, status);

		List<Date> targetLastDate = new List<Date>(lastDate.size());
		for (Integer value : lastDate) {
			targetLastDate.add(Date.today() + value);
		}
		result = setVehicleField('Vehicle__c', 'Vehicle_Last_Maintenance_Date__c', result, targetLastDate);

		List<Date> targetNextDate = new List<Date>(nextDate.size());
		for (Integer value : nextDate) {
			targetNextDate.add(Date.today() + value);
		}
		result = setVehicleField('Vehicle__c', 'Vehicle_Next_Maintenance_Date__c', result, targetNextDate);

		result = setVehicleField('Vehicle__c', 'Vehicle_Last_Maintenance__c', result, lastMaintenance);

		return result;
	}

	public static List<Maintenance__c> createMaintemance() {
		List<Maintenance__c> result = new List<Maintenance__c>();
		return result;
	}

	public static List<Vehicle__c> setVehicleField(
		String objectName,
		String objectField,
		List<sObject> target,
		List<String> value
	) {
		if (null == value || value.size() == 0) {
			return target;
		}
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

	public static List<Vehicle__c> setVehicleField(
		String objectName,
		String objectField,
		List<sObject> target,
		List<Date> value
	) {
		if (null == value || value.size() == 0) {
			return target;
		}
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

	public static List<Vehicle__c> setVehicleField(
		String objectName,
		String objectField,
		List<sObject> target,
		List<sObject> value
	) {
		if (null == value || value.size() == 0) {
			return target;
		}
		List<sObject> tmpResult = new List<sObject>();
		if (target.size() == 0) {
			for (sObject parameter : value) {
				Schema.SObjectType type = Schema.getGlobalDescribe().get(objectName);
				sObject vehicle = type.newSObject();
				vehicle.put(objectField, parameter);
				tmpResult.add(vehicle);
			}
		} else {
			for (SObject oldVehicle : target) {
				for (sObject parameter : value) {
					SObject vehicle = oldVehicle.clone();
					vehicle.put(objectField, parameter);
					tmpResult.add(vehicle);
				}
			}
		}
		return tmpResult;
	}
}
