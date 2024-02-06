package progetto.visitors.typechecking;

public interface Type {
	default void checkEqual(Type found) throws TypecheckerException {
		if (!equals(found))
			throw new TypecheckerException(found.toString(), toString());
	}

	default PairType checkIsPairType() throws TypecheckerException {
		if (this instanceof PairType pt)
			return pt;
		throw new TypecheckerException(toString(), PairType.TYPE_NAME);
	}

	default Type getFstPairType() throws TypecheckerException {
		return checkIsPairType().getFstType();
	}

	default Type getSndPairType() throws TypecheckerException {
		return checkIsPairType().getSndType();
	}

	default VectorType checkIsVectorType() throws TypecheckerException { //PROGETTO
		if (this instanceof VectorType vt)
			return vt;
		throw new TypecheckerException(toString(), VectorType.TYPE_NAME);
	}
}
