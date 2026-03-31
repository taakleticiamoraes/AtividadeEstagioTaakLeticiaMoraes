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
}