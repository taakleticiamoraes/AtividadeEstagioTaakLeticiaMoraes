public class PedidoTriggerHandler extends TriggerHandler {

    protected override void beforeInsert(){
        ImpostoService.applyImposto(Trigger.new);
    }

    protected override void beforeUpdate(){
        ImpostoService.applyImposto(Trigger.new);
    }
}