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
}