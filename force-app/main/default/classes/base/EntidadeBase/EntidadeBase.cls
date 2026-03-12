public abstract class EntidadeBase {

    public final String id;

    public EntidadeBase() {
        this.id = this.gerarIdUnico();
    }

    private String gerarIdUnico() {
        return String.valueOf(Crypto.getRandomLong());
    }

    public Boolean equals(Object obj) {
        if (obj == null) return false;

        if (!(obj instanceof EntidadeBase)) return false;

        EntidadeBase outra = (EntidadeBase) obj;

        return this.id == outra.id;
    }

    public override Integer hashCode() {
        return this.id.hashCode();
    }
}