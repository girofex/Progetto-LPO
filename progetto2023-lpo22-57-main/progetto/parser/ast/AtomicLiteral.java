package progetto.parser.ast;

public abstract class AtomicLiteral<T> implements Exp {

	protected final T value;

	public AtomicLiteral(T n) {
		this.value = n;
	}

	@Override
	public String toString() {
		return getClass().getSimpleName() + "(" + value + ")";
	}
}
