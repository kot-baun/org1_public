Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new List<String>{ 'kamkaliev@gmail.com' };
mail.setToAddresses(toAddresses);
mail.setSubject('Vehicle manage - email to driver');
mail.setPlainTextBody('test email');
System.debug(mail);

List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
