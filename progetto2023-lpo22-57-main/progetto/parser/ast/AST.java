package progetto.parser.ast;

import progetto.visitors.Visitor;

public interface AST {
	<T> T accept(Visitor<T> visitor);
}
