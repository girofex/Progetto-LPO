package progetto.parser.ast;

import static java.util.Objects.requireNonNull;

import progetto.visitors.Visitor;

// Creazione Vector per l'implementazione dei costruttori e della chiamata al visitor
public class Vector implements Exp {
    private final Exp exp1;
    private final Exp exp2;

    public Vector(Exp exp1, Exp exp2) {
		this.exp1 = requireNonNull(exp1);
		this.exp2 = requireNonNull(exp2);
	}

    @Override
    public <T> T accept(Visitor<T> visitor) {
        return visitor.visitVector(exp1, exp2);
    }

    @Override
    public String toString() {
        return getClass().getSimpleName() + "(" + exp1 + ", " + exp2 + ")";
    }
}
