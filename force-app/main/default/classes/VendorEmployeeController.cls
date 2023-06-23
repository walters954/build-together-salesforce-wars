/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class VendorEmployeeController {
    
    @AuraEnabled(cacheable=true)
    public static Master_Title_List__c getCurrentRecord(String currentRecordID){
        Master_Title_List__c currentRecord = new Master_Title_List__c();
        If(currentRecordID!=null){
            currentRecord = [SELECT Id,Name,Security_Title__c,Studio__c 
                             FROM Master_Title_List__c 
                             WHERE Id=:currentRecordID 
                             LIMIT 1];   
        }
        return currentRecord;        
    }
    
    @AuraEnabled (cacheable=true)
    public static List<QueryResult> getVendorRecords(String searchKey){
        System.debug('===searchKey'+searchKey);
        List<QueryResult> lstReturnResult = new List<QueryResult>();
        if(searchKey.equals('*')){
            searchKey = '';
        } 
        String vendorName ='%' + searchKey + '%';
        String vendorId = '%'+ searchKey + '%';  
        System.debug('===vendorname==='+vendorName);
        List<Master_Vendor_List__c> vendorRecords = [SELECT Id,Name,SHIELD_Vendor_ID__c,VendorName__c,Studio__c 
                                                     FROM Master_Vendor_List__c
                                                     WHERE VendorName__c LIKE:vendorName 
                                                     OR SHIELD_Vendor_ID__c LIKE:vendorId
                                                     LIMIT 50000];
        for(Master_Vendor_List__c vendorRecord:vendorRecords){                
            QueryResult result = new QueryResult();
            result.recordId = vendorRecord.Id;
            result.recordNameId = vendorRecord.VendorName__c+'-'+vendorRecord.SHIELD_Vendor_ID__c;
            lstReturnResult.add(result);               
        }
        System.debug('====lstReturnResult'+lstReturnResult);
        return lstReturnResult;
    }
    
    public class QueryResult {
        @AuraEnabled public String recordId;        
        @AuraEnabled public String recordNameId;
    }
    
   @AuraEnabled (cacheable=false)
    public static TSO_Title__c createSelectedVendors(list<String> selectedVendorIds, String currentRecordId){ 
        System.debug('===selectedVendorIds'+selectedVendorIds);
        System.debug('===currentRecordId'+currentRecordId);
        Master_Title_List__c currentRecord = new Master_Title_List__c();
        If(currentRecordId!=null){
            currentRecord = [SELECT Id,Name,Security_Title__c,Studio__c 
                             FROM Master_Title_List__c 
                             WHERE Id=:currentRecordId 
                             LIMIT 1];   
        }
        
        List<Master_Vendor_List__c> masterVendorRecords = [SELECT Id,Name,SHIELD_Vendor_ID__c,VendorName__c,Studio__c 
                                                           FROM Master_Vendor_List__c
                                                           WHERE Id=:selectedVendorIds
                                                           LIMIT 50000];
        
        TSO_Title__c tsoTitle = new TSO_Title__c();
        tsoTitle.Name = currentRecord.Security_Title__c;
        Database.SaveResult tsoTitleRecord = Database.insert(tsoTitle, false);
        
        list<TSO_Vendor__c> tsoVendorsToInsert = new list<TSO_Vendor__c>();
        If(masterVendorRecords!=null && !masterVendorRecords.IsEmpty()){
            for(Master_Vendor_List__c masterVendorRecord: masterVendorRecords){
                TSO_Vendor__c tsoVendorRecord = new TSO_Vendor__c();
                tsoVendorRecord.Title__c  = tsoTitleRecord.getId();
                tsoVendorRecord.VendorName__c  = masterVendorRecord.VendorName__c;
                tsoVendorRecord.SHIELD_Vendor_ID__c = masterVendorRecord.SHIELD_Vendor_ID__c;
                tsoVendorsToInsert.add(tsoVendorRecord);
            }  
        }
        If(tsoVendorsToInsert!=null && !tsoVendorsToInsert.isEmpty()){
            Insert tsoVendorsToInsert;
        }
        return tsoTitle;
    }
    
    
    /*
     * list<String> selectedVendorIds = new list<String>{'a0G3h000007fqqkEAA','a0G3h000007fqqQEAQ'};
		VendorEmployeeController.getRelatedEmployees(selectedVendorIds);
	*/
    
    @AuraEnabled (cacheable=true)
    public static list<VendorRecord> getRelatedEmployees(list<String> selectedVendorIds){
         System.debug('===selectedVendorIds'+selectedVendorIds);
        list<VendorRecord> vendorWrapperRecords = new list<VendorRecord>();        
        Map<Id,Master_Vendor_List__c> masterVendorRecords = 
            new Map<Id,Master_Vendor_List__c>([SELECT Id,Name,SHIELD_Vendor_ID__c,VendorName__c,Studio__c 
                                               FROM Master_Vendor_List__c WHERE Id=:selectedVendorIds]);        
        System.debug('===masterVendorRecords'+masterVendorRecords.Keyset());
        list<Master_Employee_List__c> relatedEmployees = [SELECT Employee_Email__c,Employee_Name__c,Id,Name,Vendor_Name__c,Role__c 
                                                          FROM Master_Employee_List__c
                                                          WHERE Vendor_Name__c=:selectedVendorIds];        
        Map<String,list<Master_Employee_List__c>> mapVendorIdWithEmployeeRecords = new Map<String,list<Master_Employee_List__c>>();        
        if(relatedEmployees!=null && !relatedEmployees.IsEmpty()){
            for(Master_Employee_List__c   relatedEmployee: relatedEmployees){
                if(!mapVendorIdWithEmployeeRecords.ContainsKey(relatedEmployee.Vendor_Name__c) && relatedEmployee.Vendor_Name__c!=null){
                    mapVendorIdWithEmployeeRecords.put(relatedEmployee.Vendor_Name__c, new list<Master_Employee_List__c>{relatedEmployee}); 
                }else{
                    mapVendorIdWithEmployeeRecords.get(relatedEmployee.Vendor_Name__c).add(relatedEmployee);
                }              
            }
        }
        System.debug('===mapVendorIdWithEmployeeRecords'+mapVendorIdWithEmployeeRecords.keyset());       
        if(mapVendorIdWithEmployeeRecords.keyset() != null){
            for(String vendorRecordID: mapVendorIdWithEmployeeRecords.keyset()){
                VendorRecord vendorWrapper = new VendorRecord();
                Master_Vendor_List__c vendorRecord = new Master_Vendor_List__c();
                if(masterVendorRecords.ContainsKey(vendorRecordID)){
                    vendorRecord =  masterVendorRecords.get(vendorRecordID); 
                }
                vendorWrapper.vendorRecordId = vendorRecord.Id;
                vendorWrapper.vendorName = vendorRecord.VendorName__c;
                vendorWrapper.vendorId = vendorRecord.SHIELD_Vendor_ID__c;                                
                list<EmployeeRecord> employeeWrapperRecords = new list<EmployeeRecord>();
                list<EmployeeItem> employeeItems = new list<EmployeeItem>();
                list<Master_Employee_List__c> employeeRecords = new list<Master_Employee_List__c>();
                if(mapVendorIdWithEmployeeRecords.ContainsKey(vendorRecordID)){
                    employeeRecords = mapVendorIdWithEmployeeRecords.get(vendorRecordID);
                    if(employeeRecords!=null && !employeeRecords.IsEmpty()){
                        for(Master_Employee_List__c employeeRecord: employeeRecords){
                            EmployeeRecord  employeeWrapper = new EmployeeRecord();
                            EmployeeItem item = new EmployeeItem();
                            item.value = employeeRecord.Id;
                            item.label = employeeRecord.Employee_Name__c;
                            employeeWrapper.employeeRecordId = employeeRecord.Id;
                            employeeWrapper.employeeName = employeeRecord.Employee_Name__c;
                            employeeWrapper.employeeEmail = employeeRecord.Employee_Email__c;
                            employeeWrapper.employeeRole = employeeRecord.Role__c;
                            employeeWrapperRecords.add(employeeWrapper);
                            employeeItems.add(item);
                        }
                    }
                }                
                vendorWrapper.employeeRecords = employeeWrapperRecords;
                vendorWrapper.employeeItems = employeeItems;
                System.debug('===vendorWrapper'+vendorWrapper);
                vendorWrapperRecords.add(vendorWrapper);
            }   
        }       
        return vendorWrapperRecords;
    }
    
    public class VendorRecord {
        @AuraEnabled public String vendorRecordId;        
        @AuraEnabled public String vendorName;
        @AuraEnabled public String vendorId;
        @AuraEnabled public list<EmployeeRecord> employeeRecords;
        @AuraEnabled public list<EmployeeItem> employeeItems;
    }
    
    public class EmployeeRecord {
        @AuraEnabled public String employeeRecordId; 
        @AuraEnabled public String employeeName;
        @AuraEnabled public String employeeEmail;
        @AuraEnabled public String employeeRole;
    }
    public class EmployeeItem {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
    }
    
}