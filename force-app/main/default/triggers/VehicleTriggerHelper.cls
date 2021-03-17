public class VehicleTriggerHelper {
	//resources
	public static List<Vehicle__c> targetVehicles = new List<Vehicle__c>();
	public static List<Maintenance__c> targetMaintenances = new List<Maintenance__c>();
	public static Map<Contact, String> targetDrivers = new Map<Contact, String>();

	public static final String MESSAGE_NEW_MAINTENANCE = 'new_mainanace';
	static final String MESSAGE_NEW_MAINTENANCE_BODY = 'New maintenance is scheduled for vehicle {0} from {1} to {2}';
	public static final String MESSAGE_STATUS_CHANGE = 'status_change';
	public static final String DATE_VALIDATION_ERROR =
		'Date validation error at the object Vehicle with ID {0} and description {1}.' +
		'The next maintenance date must be hightrer than the last maintenance date, but the last maintemamce date is {2} and the next is {3}';

	/**
	 * filter and validate values for the new maintenance process and update their Last Maintenance Date value
	 */
	public static void prepeareVehicleData(List<Vehicle__c> oldList, List<Vehicle__c> newList) {
		for (Vehicle__c vehicle : newList) {
			Vehicle__c oldVehicle = oldList.get(oldList.indexOf(vehicle));

			//filter, Next Maintenance Date is under update
			if (vehicle.Vehicle_Next_Maintenance_Date__c != oldVehicle.Vehicle_Next_Maintenance_Date__c) {
				//validate, Next Maintenance Date is on the future
				if (vehicle.Vehicle_Last_Maintenance_Date__c < oldVehicle.Vehicle_Next_Maintenance_Date__c) {
					//update
					vehicle.Vehicle_Last_Maintenance_Date__c = oldVehicle.Vehicle_Next_Maintenance_Date__c;
					targetVehicles.add(vehicle);
				} else {
					String errMsg = String.format(
						DATE_VALIDATION_ERROR,
						new List<Object>{
							vehicle.Id,
							vehicle.Vehicle_model_description__c,
							vehicle.Vehicle_Last_Maintenance_Date__c,
							vehicle.Vehicle_Next_Maintenance_Date__c
						}
					);
					Trigger.new.get(newList.indexOf(vehicle)).addError(errMsg);
				}
			}
		}
	}

	/**
	 * crate maintenance objects according to task
	 */
	public static void createMaintenanceRecords() {
		Maintenance_Service__c defaultServiecs = [
			SELECT Id
			FROM Maintenance_Service__c
			WHERE Maintenance_default__c = TRUE
			WITH SECURITY_ENFORCED
			LIMIT 1
		];

		//todo try-catch, read about
		for (Vehicle__c vehicle : targetVehicles) {
			Maintenance__c tmp = new Maintenance__c();
			tmp.Maintenance_from_date__c = vehicle.Vehicle_Next_Maintenance_Date__c;
			tmp.Maintenance_Service__c = vehicle.Vehicle_Last_Maintenance__c == null
				? defaultServiecs.Id
				: vehicle.Vehicle_Last_Maintenance__r.Maintenance_Service__c;
			tmp.Maintenance_status__c = 'Scheduled';
			tmp.Vehicle__c = vehicle.Id;
			vehicle.Vehicle_Last_Maintenance__c = tmp.Id;
			targetMaintenances.add(tmp);
		}
	}
	/**
	 * check, that the Driver exist in the Vehicle record, and have contact e-mail
	 * generate e-mail message to the valide drivers
	 */
	public static void prepeareDriversData(String type) {
		for (Vehicle__c vehicle : targetVehicles) {
			Contact driver = vehicle.Vehicle_driver__r;
			if (null == driver || driver.Email == '') {
				continue;
			}
			String msg = '';
			if (type == MESSAGE_NEW_MAINTENANCE) {
				msg = String.format(
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

			if (msg.length() > 0)
				targetDrivers.put(driver, msg);
		}
	}

	public static void sendMessageToDrivers() {
		List<Messaging.SingleEmailMessage> mailToSent = new List<Messaging.SingleEmailMessage>(targetDrivers.size());
		for (Contact driver : targetDrivers.keySet()) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new List<String>{ driver.Email };
			mail.setToAddresses(toAddresses);
			mail.setSubject('Vehicle manage - email to driver');
			mail.setPlainTextBody(targetDrivers.get(driver));
			mailToSent.add(mail);
		}

		Messaging.SendEmailResult[] results = Messaging.sendEmail(mailToSent);
		inspectResults(results);
	}

	// Public method
	void sendMail(String address, String subject, String body) {
		// Create an email message object
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new List<String>{ address };
		mail.setToAddresses(toAddresses);
		mail.setSubject(subject);
		mail.setPlainTextBody(body);
		// Pass this email message to the built-in sendEmail method
		// of the Messaging class

		//!!!! List
		Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });

		// Call a helper method to inspect the returned results
		inspectResults(results);
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

	public static void saveMaintenanceRecords() {
		insert targetMaintenances;
	}

	public static void saveTargetVehicleRecords() {
		insert targetVehicles;
	}
}
