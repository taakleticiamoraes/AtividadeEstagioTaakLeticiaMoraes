public class LocalAssociadoService {

    public static void handleInsert(List<Local_Associado__c> registros){

        List<AccountTeamMember> membros = new List<AccountTeamMember>();

        for(Local_Associado__c la : registros){

            if(la.Conta__c == null || la.Usuario__c == null){
                continue;
            }

            membros.add(new AccountTeamMember(
                AccountId = la.Conta__c,
                UserId = la.Usuario__c,
                TeamMemberRole = 'Representante'
            ));
        }

        if(!membros.isEmpty()){
            insert membros;
        }
    }

    public static void handleUpdate(
        List<Local_Associado__c> novos,
        Map<Id, Local_Associado__c> antigos
    ){
        System.debug('Update executado');
    }

    public static void handleDelete(List<Local_Associado__c> antigos){
        System.debug('Delete executado');
    }
}