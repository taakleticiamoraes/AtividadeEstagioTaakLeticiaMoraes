trigger TaskTrigger on Task (before insert) {
    //esse trigger vai rodar antes de inserir uma task nova
    //pilha de Ids dos Cases relacionados às Tasks que estão sendo criadas
    Set<Id> caseIds = new Set<Id>();

    // pegar os Cases das Tasks que estão sendo criadas, e armazena em t
    for(Task t : Trigger.new){
        //verificar se a Task tem um WhatId relacionado a um Case (prefixo '500')
        if(t.WhatId != null && String.valueOf(t.WhatId).startsWith('500')){
            caseIds.add(t.WhatId);
        }
    }

    //caso não haja Cases relacionados, não precisa continuar a execução do trigger
    if(caseIds.isEmpty()){
        return;
    }

    // buscar Tasks abertas nesses Cases
    List<Task> tasksAbertas = [
        SELECT Id, WhatId, Status
        FROM Task
        WHERE WhatId IN :caseIds
        AND Status IN ('Not Started','In Progress','Waiting on someone else')
    ];
    //onde Status IN ('Not Started','In Progress','Waiting on someone else') significa que a Task está em aberto, ou seja, não foi concluída ou cancelada.
    Map<Id, Boolean> caseComTaskAberta = new Map<Id, Boolean>();

    //serve para marcar os Cases que já possuem Tasks abertas, para facilitar a validação posteriormente
    for(Task t : tasksAbertas){
        caseComTaskAberta.put(t.WhatId, true);
    }

    // validar antes de inserir
    for(Task t : Trigger.new){

        //verifica se ja tem Task aberta para o mesmo Case
        if(caseComTaskAberta.containsKey(t.WhatId)){

            t.addError('Já existe uma tarefa em aberto nesse case. Encerre-a antes de abrir uma nova.');

        }

    }

}