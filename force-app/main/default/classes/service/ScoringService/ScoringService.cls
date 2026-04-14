public class ScoringService {
    public static Integer calculateFreightScore(
        Freight__c freight,
    Id productId,
    Id hierarchyId,
    Id dcId,
    Id cityId,
    Id stateId,
    Id countryId
    ){
        Integer score = 0;
        
        if(freight.Product__c != null){
            if(freight.Product__c != productId) return -1;
            score += 100;
        }
        else if(freight.Product_Hierarchy__c != null){
            if(freight.Product_Hierarchy__c != hierarchyId) return -1;
            score += 50;
        }
        
        if(freight.Distribution_Center__c != dcId){
            return -1;
        }
        
        if(freight.City__c != null){
            if(freight.City__c != cityId) return -1;
            score += 30;
        }
        else if(freight.State__c != null){
            if(freight.State__c != stateId) return -1;
            score += 20;
        }
        else if(freight.Country__c != null){
            if(freight.Country__c != countryId) return -1;
            score += 10;
        }
        
        return score;
    }
    
    public static Integer calculateMarginScore(
        Margin__c margin,
    Id productId,
    Id hierarchyId,
    Id accountId,
    Id groupAccountId,
    Id cityId,
    Id stateId,
    Id countryId
    ){
        Integer score = 0;
        
        if(margin.Product__c != null){
            if(margin.Product__c != productId) return -1;
            score += 100;
        } else if(margin.Product_Hierarchy__c != null){
            if(margin.Product_Hierarchy__c != hierarchyId) return -1;
            score += 80;
        }
        
        if(margin.Account__c != null){
            if(margin.Account__c != accountId) return -1;
            score += 60;
        } else if(margin.Group_Account__c != null){
            if(margin.Group_Account__c != groupAccountId) return -1;
            score += 40;
        }
        
        if(margin.City__c != null){
            if(margin.City__c != cityId) return -1;
            score += 30;
        } else if(margin.State__c != null){
            if(margin.State__c != stateId) return -1;
            score += 20;
        } else if(margin.Country__c != null){
            if(margin.Country__c != countryId) return -1;
            score += 10;
        }
        
        return score;
    }
}