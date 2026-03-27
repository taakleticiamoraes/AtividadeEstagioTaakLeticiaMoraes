trigger PedidoTrigger on OrderItem (before insert, before update) {
    new PedidoTriggerHandler().run();
}