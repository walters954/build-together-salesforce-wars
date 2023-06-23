public class DailyLeadProcessor implements Schedulable  {

    Public void execute(SchedulableContext SC){

       List<Lead> LeadObj=[SELECT Id from Lead where LeadSource=null limit 200]; 

        for(Lead l:LeadObj){

            l.LeadSource='Dreamforce';

            update l;

        }

    }

}