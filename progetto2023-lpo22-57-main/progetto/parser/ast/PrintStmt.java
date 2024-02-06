package progetto.parser.ast;

import static java.util.Objects.requireNonNull;

import progetto.visitors.Visitor;

public class PrintStmt implements Stmt {
	private final Exp exp;

	public PrintStmt(Exp exp) {
		this.exp = requireNonNull(exp);
	}

	@Override
	public String toString() {
		return getClass().getSimpleName() + "(" + exp + ")";
	}
	
	@Override
	public <T> T accept(Visitor<T> visitor) {
		return visitor.visitPrintStmt(exp);
	}
}
