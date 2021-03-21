public class VehicleTriggerHelper {
	//resources
	public static List<Vehicle__c> targetVehicles;
	public static List<Maintenance__c> targetMaintenances;
	public static Map<Contact, String> targetDrivers;
	public static final String WELCOME_DRIVER_MESSAGE = 'Hi, {0}. News for you:\n';
	public static final String MESSAGE_NEW_MAINTENANCE = 'new_mainanace';
	public static final String MESSAGE_NEW_MAINTENANCE_BODY = 'New maintenance is scheduled for vehicle {0} from {1} to {2} date\n';
	public static final String MESSAGE_STATUS_CHANGE = 'status_change';

	public static final string VEHICLE_NEXT_MAINTENANCE_DATE_NULL_EXEPTION = 'the next maintenance creation process can be executed when the next maintenance date is scheduled, but it does not happen';
	public static final String DATE_VALIDATION_ERROR =
		'Date validation error at the object Vehicle with ID {0} and description {1}.' +
		'The next maintenance date must be hightrer than the last maintenance date, but the last maintemamce date is {2} and the next is {3}';

	public static final string DEFAULT_MAINTENANCE_STATUS = 'Scheduled';

	/**
	 * initialize/clean up static variables
	 */
	private static void init() {
		targetVehicles = new List<Vehicle__c>();
		targetMaintenances = new List<Maintenance__c>();
		targetDrivers = new Map<Contact, String>();
	}
	/**
	 * applied during the update process
	 * filter and validate values for the new maintenance process and update their Last Maintenance Date value
	 * valid values are stored in a static context
	 */

	public static void validateVehicleData(Map<Id, Vehicle__c> oldMap, map<Id, Vehicle__c> newMap) {
		init();

		System.debug(
			'update process begin, oldMap size ' +
			oldMap.size() +
			' newMap size ' +
			newMap.size() +
			' and targetMaintenances sizee at ' +
			targetMaintenances.size()
		);

		for (Vehicle__c newVehicle : newMap.values()) {
			Vehicle__c oldVehicle = oldMap.get(newVehicle.Id);

			if (null == newVehicle.Vehicle_Next_Maintenance_Date__c) {
				System.debug(VEHICLE_NEXT_MAINTENANCE_DATE_NULL_EXEPTION);
				continue;
			}
			//validate, Next Maintenance Date is on the future
			//TODO hack isn't cool, check order of execution
			if (
				Date.today() > newVehicle.Vehicle_Next_Maintenance_Date__c ||
				newVehicle.Vehicle_Last_Maintenance_Date__c > newVehicle.Vehicle_Next_Maintenance_Date__c
			) {
				String errMsg = String.format(
					'On update process:' + DATE_VALIDATION_ERROR,
					new List<Object>{
						newVehicle.Id,
						newVehicle.Vehicle_model_description__c,
						newVehicle.Vehicle_Last_Maintenance_Date__c,
						newVehicle.Vehicle_Next_Maintenance_Date__c
					}
				);
				System.debug(errMsg);
				newMap.get(newVehicle.Id).addError(errMsg);
				continue;
			}

			//filter, Next Maintenance Date is under update
			if (newVehicle.Vehicle_Next_Maintenance_Date__c != oldVehicle.Vehicle_Next_Maintenance_Date__c) {
				//update
				newVehicle.Vehicle_Last_Maintenance_Date__c = oldVehicle.Vehicle_Next_Maintenance_Date__c;
				targetVehicles.add(newVehicle);
			}
		}
		System.debug(
			'update process complete, targetVehicles size ' +
			+targetVehicles.size() +
			' and targetMaintenances size at ' +
			targetMaintenances.size()
		);
	}
	/**
	 * applied during the insert process
	 * filter and validate values for the new maintenance process
	 * valid values are stored in a static context
	 */
	public static void validateVehicleData(List<Vehicle__c> newList) {
		init();
		System.debug(
			'insert process begin, newList size ' +
			+newList.size() +
			' and targetMaintenances sizee at ' +
			targetMaintenances.size()
		);
		for (Vehicle__c newVehicle : newList) {
			if (null == newVehicle.Vehicle_Next_Maintenance_Date__c) {
				System.debug(VEHICLE_NEXT_MAINTENANCE_DATE_NULL_EXEPTION);
				continue;
			}

			//validate, Next Maintenance Date is on the future
			if (Date.today() > newVehicle.Vehicle_Next_Maintenance_Date__c) {
				String errMsg = String.format(
					'On insert process:' + DATE_VALIDATION_ERROR,
					new List<Object>{
						newVehicle.Id,
						newVehicle.Vehicle_model_description__c,
						newVehicle.Vehicle_Last_Maintenance_Date__c,
						newVehicle.Vehicle_Next_Maintenance_Date__c
					}
				);
				System.debug(errMsg);
				System.debug(newVehicle.Id);
				newList.get(newList.indexOf(newVehicle)).addError(errMsg);
				continue;
			}
			//no filter in insert process
			targetVehicles.add(newVehicle);
		}
		System.debug(
			'insert process complete, targetVehicles size ' +
			+targetVehicles.size() +
			' and targetMaintenances sizee at ' +
			targetMaintenances.size()
		);
	}

	/**
	 * crate maintenance objects and records according to task
	 */
	public static void createMaintenanceRecords() {
		System.debug(
			'maintenance creation begin with targetVehicles size at ' +
			targetVehicles.size() +
			' and targetMaintenances sizee at ' +
			targetMaintenances.size()
		);

		Maintenance_Service__c defaultService;
		try {
			defaultService = [
				SELECT Id, Maintenance_default__c
				FROM Maintenance_Service__c
				WHERE Maintenance_default__c = TRUE
				WITH SECURITY_ENFORCED
				LIMIT 1
			];
		} catch (QueryException ex) {
			System.debug('need to add at least one default Maintenance Service');
			//TODO do it better
			return;
		}
		System.debug('default service exist ' + defaultService);
		List<Vehicle__c> fullVehicle = [
			SELECT
				Id,
				Vehicle_Next_Maintenance_Date__c,
				Vehicle_Last_Maintenance__r.Maintenance_Service__c,
				Vehicle_Last_Maintenance__r.Maintenance_Service__r.Maintenance_default__c
			FROM Vehicle__c
			WHERE Id IN :targetVehicles
		];
		System.debug('maintenance creation, request fullVehicles with size at ' + fullVehicle.size());

		for (Vehicle__c vehicle : fullVehicle) {
			Maintenance__c tmp = new Maintenance__c();
			tmp.Maintenance_from_date__c = vehicle.Vehicle_Next_Maintenance_Date__c;

			if (null == vehicle.Vehicle_Last_Maintenance__c) {
				tmp.Maintenance_Service__c = defaultService.Id;
			} else {
				tmp.Maintenance_Service__c = vehicle.Vehicle_Last_Maintenance__r.Maintenance_Service__c;
			}
			tmp.Maintenance_status__c = DEFAULT_MAINTENANCE_STATUS;
			tmp.Vehicle__c = vehicle.Id;
			targetMaintenances.add(tmp);
		}
		System.debug('maintenance creation complete with targetMaintenance size at ' + targetMaintenances.size());
		insert targetMaintenances;
	}
	/**
	 * Cross-reference between vehicles and maintenance.
	 * This is the latest change in vehicle data.
	 */
	public static void assignMaintenanceToVehicle() {
		System.debug(
			'assign begin with targetMaintenance size at ' +
			targetMaintenances.size() +
			'and targetVehicles size at ' +
			targetVehicles.size()
		);
		Integer count = 0;
		for (Vehicle__c vehicle : targetVehicles) {
			for (Maintenance__c maintenance : targetMaintenances) {
				if (maintenance.Vehicle__c == vehicle.Id) {
					// Maintenance__c mmm = vehicle.Vehicle_Last_Maintenance__r;
					vehicle.Vehicle_Last_Maintenance__c = maintenance.Id;
					count++;
				}
			}
		}
		System.debug(
			'on assign maintenance size targetVehicles  ' +
			targetVehicles.size() +
			'size targetMaintenance ' +
			targetMaintenances.size()
		);
		System.debug('assign complete  with execution count ' + count);
	}

	/**
	 * check, that the Driver exist in the Vehicle record, and have contact e-mail
	 * generate e-mail message to the valide drivers
	 */
	public static void prepeareDriversData(String type) {
		System.debug('prepare driver data begin with targetVehicles size at ' + targetVehicles.size());

		for (Vehicle__c vehicle : targetVehicles) {
			Contact driver = vehicle.Vehicle_driver__r;
			if (null == driver || null == driver.Name || null == driver.Email) {
				continue;
			}
			//TODO case, when one driver for two vehicles
			String msg = targetDrivers.get(driver);
			//welcome message
			if (null == msg) {
				msg = String.format(WELCOME_DRIVER_MESSAGE, new List<Object>{ driver.Name });
			}
			if (type == MESSAGE_NEW_MAINTENANCE) {
				//new maintenance message
				msg += String.format(
					MESSAGE_NEW_MAINTENANCE_BODY,
					new List<Object>{
						vehicle.Vehicle_plate_number__c,
						vehicle.Vehicle_Last_Maintenance__r.Maintenance_from_date__c,
						vehicle.Vehicle_Last_Maintenance__r.Maintenance_due_date__c
					}
				);
			}
			if (type == MESSAGE_STATUS_CHANGE) {
				//TODO
			}

			if (msg.length() > 0) {
				targetDrivers.put(driver, msg);
			}
		}
		System.debug('prepare driver data complete with targetDrivers size at ' + targetDrivers.size());
	}

	/**
	 * sent email service
	 * @return an array of result objects.
	 * Iterate through the list to inspect results.
	 */
	public static List<Messaging.SendEmailResult> sendMessageToDrivers() {
		List<Messaging.SingleEmailMessage> mailToSent = new List<Messaging.SingleEmailMessage>();
		for (Contact driver : targetDrivers.keySet()) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new List<String>{ driver.Email };
			mail.setToAddresses(toAddresses);
			mail.setSubject('Vehicle manage - email to driver');
			mail.setPlainTextBody(targetDrivers.get(driver));
			mailToSent.add(mail);
			System.debug(mail);
		}

		List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailToSent);
		inspectResults(results);
		return results;
	}

	// Helper method
	private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
		Boolean sendResult = true;

		// sendEmail returns an array of result objects.
		// Iterate through the list to inspect results.
		// In this class, the methods send only one email,
		// so we should have only one result.
		for (Messaging.SendEmailResult res : results) {
			if (res.isSuccess()) {
				System.debug('Email sent successfully');
			} else {
				sendResult = false;
				System.debug('The following errors occurred: ' + res.getErrors());
			}
		}

		return sendResult;
	}
}
