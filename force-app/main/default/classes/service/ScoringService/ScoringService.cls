public class ScoringService {
    
    public static Integer calculateTaxScore(
        Tax__c tax,
    Id productId,
    Id dcId,
    Id stateId
    ){
        if(tax.Product__c != productId) return -1;
        if(tax.Distribution_Center__c != dcId) return -1;
        if(tax.State__c != stateId) return -1;
        
        Integer score = 0;
        score += 100;
        score += 50;
        score += 20;
        
        return score;
    }
    
    
    public static Integer calculateFreightScore(
        Freight__c fr,
    Id productId,
    Id hierarchyId,
    Id dcId,
    Id cityId,
    Id stateId,
    Id countryId
    ){
        Integer score = 0;
        
        if(fr.Product__c != null){
            if(fr.Product__c != productId) return -1;
            score += 100;
        }
        else if(fr.Product_Hierarchy__c != null){
            if(fr.Product_Hierarchy__c != hierarchyId) return -1;
            score += 50;
        }
        
        if(fr.Distribution_Center__c != dcId){
            return -1;
        }
        
        if(fr.City__c != null){
            if(fr.City__c != cityId) return -1;
            score += 30;
        }
        else if(fr.State__c != null){
            if(fr.State__c != stateId) return -1;
            score += 20;
        }
        else if(fr.Country__c != null){
            if(fr.Country__c != countryId) return -1;
            score += 10;
        }
        
        return score;
    }
    
    public static Integer calculateMarginScore(
        Margin__c m,
    Id productId,
    Id hierarchyId,
    Id accountId,
    Id groupAccountId,
    Id cityId,
    Id stateId,
    Id countryId
    ){
        Integer score = 0;
        
        if(m.Product__c != null){
            if(m.Product__c != productId) return -1;
            score += 100;
        } else if(m.Product_Hierarchy__c != null){
            if(m.Product_Hierarchy__c != hierarchyId) return -1;
            score += 80;
        }
        
        if(m.Account__c != null){
            if(m.Account__c != accountId) return -1;
            score += 60;
        } else if(m.Group_Account__c != null){
            if(m.Group_Account__c != groupAccountId) return -1;
            score += 40;
        }
        
        if(m.City__c != null){
            if(m.City__c != cityId) return -1;
            score += 30;
        } else if(m.State__c != null){
            if(m.State__c != stateId) return -1;
            score += 20;
        } else if(m.Country__c != null){
            if(m.Country__c != countryId) return -1;
            score += 10;
        }
        
        return score;
    }
}