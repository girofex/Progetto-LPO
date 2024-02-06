package progetto.parser.ast;

import static java.util.Objects.requireNonNull;

import progetto.visitors.Visitor;

public class Variable implements NamedEntity, Exp {
	private final String name;

	public Variable(String name) {
		this.name = requireNonNull(name);
	}

	@Override
	public String getName() {
		return name;
	}

	@Override
	public final boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj instanceof Variable sv)
			return name.equals(sv.name);
		return false;
	}

	@Override
	public int hashCode() {
		return name.hashCode();
	}

	@Override
	public String toString() {
		return getClass().getSimpleName() + "(" + name + ")";
	}
	
	@Override
	public <T> T accept(Visitor<T> visitor) {
		return visitor.visitVariable(this);
	}
}
