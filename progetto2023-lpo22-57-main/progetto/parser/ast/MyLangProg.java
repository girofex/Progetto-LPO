package progetto.parser.ast;

import static java.util.Objects.requireNonNull;

import progetto.visitors.Visitor;

public class MyLangProg implements Prog {
	private final StmtSeq stmtSeq;

	public MyLangProg(StmtSeq stmtSeq) {
		this.stmtSeq = requireNonNull(stmtSeq);
	}

	@Override
	public String toString() {
		return getClass().getSimpleName() + "(" + stmtSeq + ")";
	}
	
	@Override
	public <T> T accept(Visitor<T> visitor) {
		return visitor.visitMyLangProg(stmtSeq);
	}
}
