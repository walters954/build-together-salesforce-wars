@isTest

public class AccountProcessorTest {

    @isTest

    public static void testNoOfContacts(){

        Account a = new Account();

        a.Name = 'Test Account';

        Insert a;

        

        Contact c = new Contact();

        c.FirstName = 'Bob';

        c.LastName =  'Willie';

        c.AccountId = a.Id;

        

        Contact c2 = new Contact();

        c2.FirstName = 'Tom';

        c2.LastName = 'Cruise';

        c2.AccountId = a.Id;

        

        List<Id> acctIds = new List<Id>();

        acctIds.add(a.Id);

        

        Test.startTest();

        AccountProcessor.countContacts(acctIds);

        Test.stopTest();

    }



}