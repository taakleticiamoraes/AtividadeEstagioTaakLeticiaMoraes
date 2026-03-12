public class RelatorioPedidoService {
    
    public static Map<Produto, Integer> produtosMaisVendidos(List<Pedido> pPedidos) {
        Map<Produto, Integer> vendas = new Map<Produto, Integer>();
        
        for (Pedido p : pPedidos) {
            for (ItemPedido item : p.getItens()) {
                
                Produto produto = item.getProduto();
                Integer quantidade = item.getQuantidade();
                
                if (vendas.containsKey(produto)) {
                    vendas.put(
                        produto,
                        vendas.get(produto) + quantidade
                    );
                } else {
                    vendas.put(produto, quantidade);
                }
            }
        }
        return vendas;
    }
    
    public static Map<String, List<Pedido>> pedidosPorCliente(
        List<Pedido> pPedidos,
        List<String> pCpfs
    ) {
        Map<String, List<Pedido>> resultado = new Map<String, List<Pedido>>();
        
        for (String cpf : pCpfs) {
            resultado.put(cpf, new List<Pedido>());
        }
        
        for (Pedido pedido : pPedidos) {
            String cpf = pedido.getCliente().getDocumento().getValor();
            
            if (resultado.containsKey(cpf)) {
                resultado.get(cpf).add(pedido);
            }
        }
        
        return resultado;
    }
}