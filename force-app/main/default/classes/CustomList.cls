public class CustomList {
    
    //We will  sort wrapper list based on count value
    //using bubble sort
    public static List<SK_sortUtilityTestWrapper> sortWrapperList(List<SK_sortUtilityTestWrapper> recList,string sortType){
        List<SK_sortUtilityTestWrapper> sortedList = new List<SK_sortUtilityTestWrapper>();
        system.debug('******sortedList before sorting in '+sortType+':'+recList);
        if(recList.size()>0){
            sortedList = recList;
            if(sortType.equalsIgnoreCase('DESC')){
                for(integer i = 0; i < sortedList.size(); i++){
                    for(integer j = 1; j < (sortedList.size()-i); j++){
                        Decimal firstValue = decimal.valueof(string.valueof(sortedList[j-1].count));
                        Decimal nextValue = decimal.valueof(string.valueof(sortedList[j].count));
                        //if firstValue < nextValue, swap the elements
                        if(firstValue < nextValue){
                            SK_sortUtilityTestWrapper tmpValue = sortedList[j-1];
                            sortedList[j-1]=sortedList[j];
                            sortedList[j]=tmpValue;
                            system.debug('******sortedList before sorting in    in if condition');
                        }
                        system.debug('******sortedList before sorting in    out of  if condition');
                    }
                }
            }else if(sortType.equalsIgnoreCase('ASC')){
                for(integer i = 0; i < sortedList.size()-1; i++){
                    for(integer j = 1; j < sortedList.size(); j++){
                        Decimal firstValue = decimal.valueof(string.valueof(sortedList[j-1].count));
                        Decimal nextValue = decimal.valueof(string.valueof(sortedList[j].count));
                        //if firstValue > nextValue, swap the elements
                        if(firstValue > nextValue){
                            SK_sortUtilityTestWrapper tmpValue = sortedList[j-1];
                            sortedList[j-1]=sortedList[j];
                            sortedList[j]=tmpValue;
                        }
                    }
                }
            }    
        }
        system.debug('******sortedList after sorting in '+sortType+':'+sortedList);
        return sortedList;
    }
    public class SK_sortUtilityTestWrapper {
        public string category{get;set;}
        public decimal count{get;set;}
        public SK_sortUtilityTestWrapper(string ss,decimal sk){
            this.category=ss;
            this.count=sk;
            
        }
    }
    public static void testWrapperListSorting(){
        List<SK_sortUtilityTestWrapper> wrapperList= new List<SK_sortUtilityTestWrapper>();
        wrapperList.add(new SK_sortUtilityTestWrapper('D',0));
        wrapperList.add(new SK_sortUtilityTestWrapper('A',0));
        wrapperList.add(new SK_sortUtilityTestWrapper('A1',0));
        wrapperList.add(new SK_sortUtilityTestWrapper('B',0));
        wrapperList.add(new SK_sortUtilityTestWrapper('C',0));
        
        // List<SK_sortUtilityTestWrapper> sortedWrapperASC=SK_sortUtilityTestWrapper.sortWrapperList(wrapperList,'ASC');
        List<SK_sortUtilityTestWrapper> sortedWrapperDESC=SK_sortUtilityTestWrapper.sortWrapperList(wrapperList,'DESC');
    }
    
}