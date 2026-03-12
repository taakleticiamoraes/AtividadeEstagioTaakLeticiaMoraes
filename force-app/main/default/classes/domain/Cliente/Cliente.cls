public class Cliente extends Pessoa {

    private Endereco endereco;
    private String telefone;

    public Endereco getEndereco() {
        return endereco;
    }

    public String getTelefone() {
        return telefone;
    }

    public Cliente(
        String pNome,
        Documento pDocumento,
        Endereco pEndereco,
        String pTelefone
    ) {
        super(pNome, pDocumento);
        this.endereco = pEndereco;
        this.telefone = pTelefone;
    }

    public override String getTipoPessoa() {
        return 'Cliente';
    }

    public override String toString() {
        return 'Cliente: ' + nome +
            ', Documento: ' + getDocumento() +
            ', Endereço: ' + endereco +
            ', Telefone: ' + telefone +
            ', ID: ' + id;
    }
}