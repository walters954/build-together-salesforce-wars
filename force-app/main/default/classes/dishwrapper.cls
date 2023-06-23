public with sharing class dishwrapper {
    @AuraEnabled(cacheable=true)
    public static String getItems(){
        Integer rowIndex = 0;
        List<itemWrap> itemWrapList = new List<itemWrap>();
        try {
            List<Item__c> itemList = [SELECT Id, Name FROM Item__c limit 20];
            for(Item__c a : itemList){
                itemWrapList.add(new itemWrap(a.Id,a.Name,rowIndex));
            rowIndex++;
            }
            return JSON.serialize(itemWrapList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class itemWrap{
        public String Id;
        public String Name;
        public Boolean isSelected;
        public Integer index;
        public itemWrap(String Id, String Name, Integer index){
            this.Id = Id;
            this.Name = Name;
            this.isSelected = false;
            this.index = index;
        }
    }
}