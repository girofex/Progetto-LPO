package progetto.parser.ast;

import progetto.visitors.Visitor;

public class EmptyStmtSeq extends EmptySeq<Stmt> implements StmtSeq {

	@Override
	public <T> T accept(Visitor<T> visitor) {
		return visitor.visitEmptyStmtSeq();
	}
}
