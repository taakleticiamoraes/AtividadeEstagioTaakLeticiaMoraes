public with sharing class CadastroDeContas {
    
    private List<Conta> contas;
    
    public CadastroDeContas() {
        this.contas = new List<Conta>();
    }
    
    public void adicionarConta(Conta conta) {
        if (conta != null) {
            contas.add(conta);
        }
    }
    
    public List<Conta> listarContas() {
        return new List<Conta>(contas);
    }
}