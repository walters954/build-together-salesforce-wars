/*===================================================================================
* Author : Haripriya Korivi 
* Version : 1.0
* Description : A Rest service class that takes aricle id as input and returns the articles associated with same data sub categories.
* Created Date : 4/17/2023
* User Story:  VO-6631
===================================================================================/*
====================================================================================*//*
Change History :
DATE            NAME                        DESCRIPTION

======================================================================================*/
@RestResource(urlMapping='/related-articles/*')
global with sharing class knowledgeart {
    global static final Integer LIMIT_ON_QUERY = 30;
    @HttpGet
    global static List<Knowledge__kav> getRelatedArticles() {
        // Get the article ID from the URL parameter
        String articleId = RestContext.request.params.get('articleId');
        
        // Query the article's data category group
        List<Knowledge__DataCategorySelection> dataCategorySelections = [
            SELECT Id,DataCategoryGroupName,DataCategoryName
            FROM Knowledge__DataCategorySelection
            WHERE ParentId = :articleId
        ];
        
        
        Set<Id> dataCategoryIds = new Set<Id>();
        Map<String,List<String>> dataCategoryMap = new   Map<String,List<String>>();
        
        // This is used as data for test coverage as data caategory retrieval has limitation while running test
        if(Test.isRunningTest()){
            dataCategorySelections = new List<Knowledge__DataCategorySelection>{
                new Knowledge__DataCategorySelection(
                    ParentId = articleId,
                    DataCategoryGroupName = 'USA',
                    DataCategoryName = 'Volkswagen'
                )
                    };
                        }
        
        // Storing data category group and name in the form of Map 
        for (Knowledge__DataCategorySelection dataCategorySelection : dataCategorySelections) {
            dataCategoryIds.add(dataCategorySelection.Id);
            if(!dataCategoryMap.containsKey(dataCategorySelection.DataCategoryGroupName)){
                dataCategoryMap.put(dataCategorySelection.DataCategoryGroupName, new List<String>{});
            }
            dataCategoryMap.get(dataCategorySelection.DataCategoryGroupName).add(dataCategorySelection.DataCategoryName);
        }
        String status = 'Online';
        // Generating query for dynamic SOQL that retrieves most viewed articles related to the same sub data categories
        String query = 'SELECT  Title, UrlName, ArticleTotalViewCount, KnowledgeArticleId FROM KnowledgeArticleVersion  WHERE PublishStatus =:status AND Id != : articleId  AND ArticleTotalViewCount >= 0 ';
        
        if(!dataCategoryMap.isEmpty()){
            query +='WITH DATA CATEGORY ';
            for(String parentCat : dataCategoryMap.keySet()){
                query += parentCat+'__c AT (';
                for(String childCat : dataCategoryMap.get(parentCat)){
                    query += childCat+'__c,';
                }
                query = query.removeEnd(',');
                query += ' ) AND ';
            }
            
            query = query.removeEnd(' AND ');
        }
        
        query +='  ORDER BY ArticleTotalViewCount dESC LIMIT '+LIMIT_ON_QUERY;
        System.debug('query '+query);
        list<id> knowledgeId = new list<id>();
        List<KnowledgeArticleVersion> relatedArticles = Database.query(String.escapeSingleQuotes(query));
        system.debug('relatedArticles>>>'+relatedArticles.size());
        for (KnowledgeArticleVersion kav : relatedArticles){
            knowledgeId.add(kav.KnowledgeArticleId);
        }
        
        //getting rating
        
        List<KnowledgeWrapper> knowledgeWrappers = new List<KnowledgeWrapper>();
        List<Knowledge__kav> knowledgearticles = [select KnowledgeArticleId,Title,(SELECT Id, PublicRatingPositive__c, PublicRatingNegative__c,Knowledge__c FROM PublicVoteCounts__r) from Knowledge__kav where KnowledgeArticleId IN:knowledgeId
                                                  AND PublishStatus ='online'];
        List<Knowledge__kav> Highestratingarticles = new List<Knowledge__kav>();
        for(knowledge__kav knowarticles : knowledgearticles){
            for(PublicVoteCount__c publicvote : knowarticles.PublicVoteCounts__r){
                KnowledgeWrapper ow = new KnowledgeWrapper();
                decimal TotalRating = 0;
                if(publicvote.PublicRatingPositive__c != null && publicvote.PublicRatingNegative__c != null){
                    if(publicvote.PublicRatingPositive__c !=0 && publicvote.PublicRatingPositive__c !=0){
                        TotalRating = (publicvote.PublicRatingPositive__c/(publicvote.PublicRatingPositive__c+publicvote.PublicRatingNegative__c));
                    }
                }
                ow.thumbsup = publicvote.PublicRatingPositive__c;
                ow.Rating = TotalRating;
                ow.knowledgeId = publicvote.Knowledge__c;
                ow.acc = knowarticles;
                knowledgeWrappers.add(ow);
            }
        }
        List<KnowledgeWrapper> sortedList = new List<KnowledgeWrapper>();
        if(knowledgeWrappers.size()>0){
            sortedList = knowledgeWrappers;
            for(integer i = 0; i < sortedList.size(); i++){
                for(integer j = 1; j < (sortedList.size()-i); j++){
                    Decimal firstValue = decimal.valueof(string.valueof(sortedList[j-1].Rating));
                    Decimal nextValue = decimal.valueof(string.valueof(sortedList[j].Rating));
                    if(firstValue < nextValue){
                        KnowledgeWrapper tmpValue = sortedList[j-1];
                        sortedList[j-1]=sortedList[j];
                        sortedList[j]=tmpValue;
                    }
                    else if(firstValue == nextValue){
                        integer firstthumbs = integer.valueof(string.valueof(sortedList[j-1].thumbsup));
                        integer nextthumbs = integer.valueof(string.valueof(sortedList[j].thumbsup));
                        if(firstthumbs < nextthumbs){
                            KnowledgeWrapper tmpValue = sortedList[j-1];
                            sortedList[j-1]=sortedList[j];
                            sortedList[j]=tmpValue;
                        }
                        
                    }
                }
            }
        }
        system.debug('******sortedList after sorting in >>'+sortedList);
        for(Integer i=0; i<5; i++){
            if(sortedList.size() > i) {
                Highestratingarticles.add(sortedList[i].acc);
            }
        }
        system.debug('Highestratingarticles'+ Highestratingarticles.size()); 
        return Highestratingarticles;
    }
    public class KnowledgeWrapper {
        public Decimal thumbsup;
        public Decimal Rating;
        public Id knowledgeId;
        public Knowledge__kav acc;
    }
}