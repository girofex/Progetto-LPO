package progetto.visitors.execution;

import static java.util.Objects.requireNonNull;

import java.util.Arrays;

public class VectorValue implements Value {
    private final IntValue[] vect;

    public VectorValue(Value dim) {
        sanityCheckDim(dim);
        this.vect = new IntValue[dim.toInt()];
        for (int i = 0; i < dim.toInt(); i++) {
            vect[i] = new IntValue(0);
        }
    }

    public VectorValue(Value index, Value dim) {
        sanityCheckIndex(index, dim);
        this.vect = new IntValue[dim.toInt()];
        for (int i = 0; i < dim.toInt(); i++) {
            vect[i] = new IntValue(0);
        }
        this.vect[index.toInt()] = new IntValue(1);
    }

    public VectorValue(IntValue[] vect) {
        this.vect = requireNonNull(vect);
    }

    private void sanityCheckDim(Value dim) {
        requireNonNull(dim);
        try {
            if (dim.toInt() < 0) {
                throw new NegativeArraySizeException();
            }
        } catch (NegativeArraySizeException e) {
            String msg = "java.lang.NegativeArraySizeException: " + dim.toString();
            throw new InterpreterException(msg, e);
        }
    }

    private void sanityCheckIndex(Value index, Value dim) {
        sanityCheckDim(dim);
        requireNonNull(index);
        try {
            if (index.toInt() < 0 || index.toInt() >= dim.toInt()) {
                throw new ArrayIndexOutOfBoundsException();
            }
        } catch (ArrayIndexOutOfBoundsException e) {
            String msg = "java.lang.ArrayIndexOutOfBoundsException: Index " + index.toString() + " out of bounds for length " + dim.toString();
            throw new InterpreterException(msg, e);
        }
    }

    public IntValue get(int index) {
        return this.vect[index];
    }

    public void set(int index, IntValue value) {
        this.vect[index] = value;
    }

    public IntValue size() {
        return new IntValue(vect.length);
    }

    @Override
    public VectorValue toVector() {
        return this;
    }

    @Override
    public final boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj instanceof VectorValue vt)
            return Arrays.equals(vect, vt.vect);
        return false;
    }

    @Override
    public int hashCode() {
        return Arrays.hashCode(vect);
    }

    @Override
    public String toString() {
        String s = "[";
        for (int i = 0; i < vect.length; i++) {
            s += vect[i].toString();
            if (i != vect.length - 1) {
                s += ";";
            }
        }
        s += "]";
        return s;
    }
}
