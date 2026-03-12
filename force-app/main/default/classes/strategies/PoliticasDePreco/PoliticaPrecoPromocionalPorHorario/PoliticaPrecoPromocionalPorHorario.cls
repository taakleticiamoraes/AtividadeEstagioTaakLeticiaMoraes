public class PoliticaPrecoPromocionalPorHorario implements PoliticaDePreco {

    private Integer horaInicio;
    private Integer horaFim;
    private Decimal desconto;

    public PoliticaPrecoPromocionalPorHorario(Integer pInicio, Integer pFim, Decimal pDesconto) {
        this.horaInicio = pInicio;
        this.horaFim = pFim;
        this.desconto = pDesconto;
    }

    public Dinheiro calcularPreco(Produto produto) {

        Integer horaAtual = Datetime.now().hour();

        if (horaAtual >= horaInicio && horaAtual <= horaFim) {
            Decimal fator = (100 - desconto) / 100;
            return produto.getPrecoBase().multiplicar(fator);
        }

        return produto.getPrecoBase();
    }
}