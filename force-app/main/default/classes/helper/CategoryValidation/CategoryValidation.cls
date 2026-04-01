public class CategoryValidation {

    public static void validateProductCategory(
        SObject record,
        Id productId,
        Id hierarchyId
    ){

        if(productId == null && hierarchyId == null){
            record.addError('You must fill Product OR Product Hierarchy.');
        }

        if(productId != null && hierarchyId != null){
            record.addError('You cannot fill both Product and Product Hierarchy.');
        }
    }

    public static void validateLocationCategory(
    SObject record,
    Id cityId,
    Id stateId,
    Id countryId
){
    Integer filledFields = 0;

    if(cityId != null) filledFields++;
    if(stateId != null) filledFields++;
    if(countryId != null) filledFields++;

    if(filledFields == 0){
        record.addError('You must fill one location field (City, State or Country).');
    }
    
    if(filledFields > 1){
        record.addError('You can only fill ONE location field (City OR State OR Country).');
    }
}
}