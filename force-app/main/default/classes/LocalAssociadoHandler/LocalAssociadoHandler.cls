public class LocalAssociadoHandler extends LocalAssociadoTriggerHandler {

    public override void afterInsert(){
        LocalAssociadoService.handleInsert(
            (List<Local_Associado__c>) Trigger.new
        );
    }

    public override void afterUpdate(){
        LocalAssociadoService.handleUpdate(
            (List<Local_Associado__c>) Trigger.new,
            (Map<Id, Local_Associado__c>) Trigger.oldMap
        );
    }

    public override void afterDelete(){
        LocalAssociadoService.handleDelete(
            (List<Local_Associado__c>) Trigger.old
        );
    }
}