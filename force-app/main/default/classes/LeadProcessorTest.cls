@isTest

public class LeadProcessorTest {

    

        @testSetup

    static void setup() {

        List<Lead> leads = new List<Lead>();

        for(Integer counter=0 ;counter <200;counter++){

            Lead lead = new Lead();

            lead.FirstName ='FirstName';

            lead.LastName ='LastName'+counter;

            lead.Company ='demo'+counter;

            leads.add(lead);

        }        

        insert leads;

    }

    

    @isTest static void test() {

        Test.startTest();

        LeadProcessor leadProcessor = new LeadProcessor();

        Id batchId = Database.executeBatch(leadProcessor);

        Test.stopTest();   

    }



}