package progetto.parser.ast;

import progetto.visitors.Visitor;

public class BoolLiteral extends AtomicLiteral<Boolean> {

	public BoolLiteral(boolean b) {
		super(b);
	}
	
	@Override
	public <T> T accept(Visitor<T> visitor) {
		return visitor.visitBoolLiteral(value);
	}
}
