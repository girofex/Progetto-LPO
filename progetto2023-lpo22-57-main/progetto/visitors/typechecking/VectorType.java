package progetto.visitors.typechecking;

public class VectorType implements Type{
    private final Type fstType;
	private final Type sndType;

    public static final String TYPE_NAME = "VECTOR";

    public VectorType(Type fstType, Type sndType) {
        this.fstType = fstType;
        this.sndType = sndType;
    }

    public Type getFstType() {
        return fstType;
    }

    public Type getSndType() {
        return sndType;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj instanceof VectorType pt)
            return fstType.equals(pt.fstType) && sndType.equals(pt.sndType);
        return false;
    }
}
