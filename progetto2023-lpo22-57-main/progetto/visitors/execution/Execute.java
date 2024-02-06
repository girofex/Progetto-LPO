package progetto.visitors.execution;

import java.io.PrintWriter;

import progetto.environments.EnvironmentException;
import progetto.environments.GenEnvironment;
import progetto.parser.ast.Block;
import progetto.parser.ast.Exp;
import progetto.parser.ast.Stmt;
import progetto.parser.ast.StmtSeq;
import progetto.parser.ast.Variable;
import progetto.visitors.Visitor;

import static java.util.Objects.requireNonNull;

public class Execute implements Visitor<Value> {

	private final GenEnvironment<Value> env = new GenEnvironment<>();
	private final PrintWriter printWriter; // output stream used to print values

	public Execute() {
		printWriter = new PrintWriter(System.out, true);
	}

	public Execute(PrintWriter printWriter) {
		this.printWriter = requireNonNull(printWriter);
	}

	// dynamic semantics for programs; no value returned by the visitor

	@Override
	public Value visitMyLangProg(StmtSeq stmtSeq) {
		try {
			stmtSeq.accept(this);
			// possible runtime errors
			// EnvironmentException: undefined variable
		} catch (EnvironmentException e) {
			throw new InterpreterException(e);
		}
		return null;
	}

	// dynamic semantics for statements; no value returned by the visitor

	@Override
	public Value visitAssignStmt(Variable var, Exp exp) {
		env.update(var, exp.accept(this));
		return null;
	}

	@Override
	public Value visitPrintStmt(Exp exp) {
		printWriter.println(exp.accept(this));
		return null;
	}

	@Override
	public Value visitVarStmt(Variable var, Exp exp) {
		env.dec(var, exp.accept(this));
		return null;
	}

	@Override
	public Value visitIfStmt(Exp exp, Block thenBlock, Block elseBlock) {
		if (exp.accept(this).toBool())
			thenBlock.accept(this);
		else if (elseBlock != null)
			elseBlock.accept(this);
		return null;
	}

	@Override
	public Value visitBlock(StmtSeq stmtSeq) {
		env.enterScope();
		stmtSeq.accept(this);
		env.exitScope();
		return null;
	}

	// dynamic semantics for sequences of statements
	// no value returned by the visitor

	@Override
	public Value visitEmptyStmtSeq() {
		return null;
	}

	@Override
	public Value visitNonEmptyStmtSeq(Stmt first, StmtSeq rest) {
		first.accept(this);
		rest.accept(this);
		return null;
	}

	// dynamic semantics of expressions; a value is returned by the visitor

	@Override
	public Value visitAdd(Exp left, Exp right) { // PROGETTO
		Value leftValue = left.accept(this);
		Value rightValue = right.accept(this);
		if (leftValue instanceof IntValue && rightValue instanceof IntValue)
			return new IntValue(((IntValue) leftValue).toInt() + ((IntValue) rightValue).toInt());
		else if (leftValue instanceof VectorValue leftVector && rightValue instanceof VectorValue rightVector) {
			if (leftVector.size().toInt() != rightVector.size().toInt()) {
				throw new InterpreterException("Vectors must have the same dimension");
			}
			VectorValue result = new VectorValue(leftVector.size());
			for (int i = 0; i < leftVector.size().toInt(); i++) {
				result.set(i, new IntValue(leftVector.get(i).toInt() + rightVector.get(i).toInt()));
			}
			return result;
		} else if (leftValue instanceof IntValue) // arrivati qui, se il primo operatore è un intero, il secondo sarà un
			throw new InterpreterException("ExpectingDynamicType Int"); // tipo inaspettato, sollevo un eccezione
		else if (leftValue instanceof VectorValue) // arrivati qui, se il primo operatore è un vettore, il secondo sarà
			throw new InterpreterException("ExpectingDynamicType Vect"); // un tipo inaspettato, sollevo un eccezione
		throw new InterpreterException("Type mismatch ADD");
	}

	@Override
	public IntValue visitIntLiteral(int value) {
		return new IntValue(value);
	}

	@Override
	public Value visitMul(Exp left, Exp right) { // PROGETTO
		Value leftValue = left.accept(this);
		Value rightValue = right.accept(this);
		if (leftValue instanceof IntValue && rightValue instanceof IntValue)
			return new IntValue(((IntValue) leftValue).toInt() * ((IntValue) rightValue).toInt());
		else if (leftValue instanceof VectorValue leftVector && rightValue instanceof VectorValue rightVector) {
			if (leftVector.size().toInt() != rightVector.size().toInt())
				throw new InterpreterException("Vectors must have the same dimension");
			int result = 0;
			for (int i = 0; i < leftVector.size().toInt(); i++) {
				result += leftVector.get(i).toInt() * rightVector.get(i).toInt();
			}
			return new IntValue(result);
		} else if ((leftValue instanceof IntValue && rightValue instanceof VectorValue) || (leftValue instanceof VectorValue && rightValue instanceof IntValue)) {
			if (leftValue instanceof IntValue) {
				VectorValue vector = new VectorValue(((VectorValue) rightValue).size());
				for (int i = 0; i < rightValue.toVector().size().toInt(); i++) {
					vector.set(i, new IntValue(leftValue.toInt() * rightValue.toVector().get(i).toInt()));
				}
				return vector;
			} else {
				VectorValue vector = new VectorValue(((VectorValue) leftValue).size());
				for (int i = 0; i < leftValue.toVector().size().toInt(); i++) {
					vector.set(i, new IntValue(leftValue.toVector().get(i).toInt() * rightValue.toInt()));
				}
				return vector;
			}
		}
		throw new InterpreterException("Type mismatch MUL");
	}

	@Override
	public IntValue visitSign(Exp exp) {
		return new IntValue(-exp.accept(this).toInt());
	}

	@Override
	public Value visitVariable(Variable var) {
		return env.lookup(var);
	}

	@Override
	public BoolValue visitNot(Exp exp) {
		return new BoolValue(!exp.accept(this).toBool());
	}

	@Override
	public BoolValue visitAnd(Exp left, Exp right) {
		return new BoolValue(left.accept(this).toBool() && right.accept(this).toBool());
	}

	@Override
	public BoolValue visitBoolLiteral(boolean value) {
		return new BoolValue(value);
	}

	@Override
	public BoolValue visitEq(Exp left, Exp right) {
		return new BoolValue(left.accept(this).equals(right.accept(this)));
	}

	@Override
	public PairValue visitPairLit(Exp left, Exp right) {
		return new PairValue(left.accept(this), right.accept(this));
	}

	@Override
	public Value visitFst(Exp exp) {
		return exp.accept(this).toPair().getFstVal();
	}

	@Override
	public Value visitSnd(Exp exp) {
		return exp.accept(this).toPair().getSndVal();
	}

	@Override
	public Value visitForeach(Variable var, Exp exp, Block thenBlock) { // PROGETTO
		VectorValue vector = exp.accept(this).toVector();
		env.enterScope();
		env.dec(var, new IntValue(1));
		for (int i = 0; i < vector.size().toInt(); i++) {
			env.update(var, vector.get(i));
			thenBlock.accept(this);
		}
		env.exitScope();
		return null;
	}

	@Override
	public Value visitVector(Exp exp1, Exp exp2) { // PROGETTO
		return new VectorValue(exp1.accept(this), exp2.accept(this));
	}

}
