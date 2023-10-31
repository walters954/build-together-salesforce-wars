@isTest

private class DailyLeadProcessorTest {

	static testMethod void testDailyLeadProcessor() {

		String CRON_EXP = '0 0 1 * * ?';

		List<Lead> lList = new List<Lead>();

	    for (Integer i = 0; i < 200; i++) {

			lList.add(new Lead(LastName='Dreamforce'+i, Company='Test1 Inc.', Status='Open - Not Contacted'));

		}

		insert lList;

		  

		Test.startTest();

		String jobId = System.schedule('DailyLeadProcessor', CRON_EXP, new DailyLeadProcessor()); 

	}

}