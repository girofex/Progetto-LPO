package progetto.visitors.typechecking;

import static progetto.visitors.typechecking.AtomicType.*;

import progetto.environments.EnvironmentException;
import progetto.environments.GenEnvironment;
import progetto.parser.ast.Block;
import progetto.parser.ast.Exp;
import progetto.parser.ast.Stmt;
import progetto.parser.ast.StmtSeq;
import progetto.parser.ast.Variable;
import progetto.visitors.Visitor;

public class Typecheck implements Visitor<Type> {

	private final GenEnvironment<Type> env = new GenEnvironment<>();

	// useful to typecheck binary operations where operands must have the same type
	private void checkBinOp(Exp left, Exp right, Type type) {
		type.checkEqual(left.accept(this));
		type.checkEqual(right.accept(this));
	}

	// static semantics for programs; no value returned by the visitor

	@Override
	public Type visitMyLangProg(StmtSeq stmtSeq) {
		try {
			stmtSeq.accept(this);
		} catch (EnvironmentException e) { // undeclared variable
			throw new TypecheckerException(e);
		}
		return null;
	}

	// static semantics for statements; no value returned by the visitor

	@Override
	public Type visitAssignStmt(Variable var, Exp exp) {
		var found = env.lookup(var);
		found.checkEqual(exp.accept(this));
		return null;
	}

	@Override
	public Type visitPrintStmt(Exp exp) {
		exp.accept(this);
		return null;
	}

	@Override
	public Type visitVarStmt(Variable var, Exp exp) {
		env.dec(var, exp.accept(this));
		return null;
	}

	@Override
	public Type visitIfStmt(Exp exp, Block thenBlock, Block elseBlock) {
		BOOL.checkEqual(exp.accept(this));
		thenBlock.accept(this);
		if (elseBlock != null)
			elseBlock.accept(this);
		return null;
	}

	@Override
	public Type visitBlock(StmtSeq stmtSeq) {
		env.enterScope();
		stmtSeq.accept(this);
		env.exitScope();
		return null;
	}

	// static semantics for sequences of statements
	// no value returned by the visitor

	@Override
	public Type visitEmptyStmtSeq() {
		return null;
	}

	@Override
	public Type visitNonEmptyStmtSeq(Stmt first, StmtSeq rest) {
		first.accept(this);
		rest.accept(this);
		return null;
	}

	// static semantics of expressions; a type is returned by the visitor

	// verifica che il tipo sia o VECTOR o INT, in tal caso restituisce tale tipo altrimenti solleva un'eccezione
    private Type checkIntOrVect(Exp exp) {
        var var = exp.accept(this);
        if(INT.equals(var) || VECTOR.equals(var))
            return var;
        throw new TypecheckerException(var.toString(), INT.toString()+ " or " + VECTOR.toString());
    }

	@Override
	public AtomicType visitAdd(Exp left, Exp right) { //PROGETTO
		var var = checkIntOrVect(left);
        var.checkEqual(right.accept(this));
        return var == INT ? INT : VECTOR;
	}

	@Override
	public AtomicType visitIntLiteral(int value) {
		return INT;
	}

	@Override
	public AtomicType visitMul(Exp left, Exp right) { //PROGETTO
		if(checkIntOrVect(left) != checkIntOrVect(right))
            return VECTOR;
        else return INT;
	}

	@Override
	public AtomicType visitSign(Exp exp) {
		INT.checkEqual(exp.accept(this));
		return INT;
	}

	@Override
	public Type visitVariable(Variable var) {
		return env.lookup(var);
	}

	@Override
	public AtomicType visitNot(Exp exp) {
		BOOL.checkEqual(exp.accept(this));
		return BOOL;
	}

	@Override
	public AtomicType visitAnd(Exp left, Exp right) {
		checkBinOp(left, right, BOOL);
		return BOOL;
	}

	@Override
	public AtomicType visitBoolLiteral(boolean value) {
		return BOOL;
	}

	@Override
	public AtomicType visitEq(Exp left, Exp right) {
		left.accept(this).checkEqual(right.accept(this));
		return BOOL;
	}

	@Override
	public PairType visitPairLit(Exp left, Exp right) {
		return new PairType(left.accept(this), right.accept(this));
	}

	@Override
	public Type visitFst(Exp exp) {
		return exp.accept(this).getFstPairType();
	}

	@Override
	public Type visitSnd(Exp exp) {
		return exp.accept(this).getSndPairType();
	}

	@Override
	public Type visitForeach(Variable var, Exp exp, Block thenBlock) { //PROGETTO
		VECTOR.checkEqual(exp.accept(this));
		env.enterScope();
		env.dec(var, INT);
		thenBlock.accept(this);
		env.exitScope();
		return null;
	}

	@Override
	public Type visitVector(Exp exp1, Exp exp2) { //PROGETTO
		INT.checkEqual(exp1.accept(this));
		INT.checkEqual(exp2.accept(this));
		return VECTOR;
	}
}
