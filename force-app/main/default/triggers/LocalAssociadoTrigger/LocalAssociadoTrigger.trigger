trigger LocalAssociadoTrigger on Local_Associado__c (
    after insert,
    after update,
    after delete
) {
    new LocalAssociadoHandler().run();
}