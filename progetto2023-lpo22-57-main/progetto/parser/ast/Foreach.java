package progetto.parser.ast;

import static java.util.Objects.requireNonNull;

import progetto.visitors.Visitor;

// Creazione Foreach per l'implementazione dei costruttori e della chiamata al visitor
public class Foreach implements Stmt {
    private final Variable var;
    private final Exp exp;
    private final Block thenBlock;

    public Foreach(Variable var, Exp exp, Block thenBlock) {
        this.var = requireNonNull(var);
		this.exp = requireNonNull(exp);
		this.thenBlock = requireNonNull(thenBlock);
	}

    @Override
    public <T> T accept(Visitor<T> visitor) {
        return visitor.visitForeach(var, exp, thenBlock);
    }

    @Override
    public String toString() {
        return getClass().getSimpleName() + "(" + var + ", " + exp + ", " + thenBlock + ")";
    }
}
