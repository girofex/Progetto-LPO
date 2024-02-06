(* environments *)

type variable = Name of string;;

exception UndeclaredVariable of variable;;

exception AlreadyDeclaredVariable of variable;;

let empty_scope = [];; 

let initial_env = [empty_scope];; (* the empty top-level scope *)

(* enter_scope: environment -> environment *)

let enter_scope env = empty_scope::env;; (* enters a new nested scope *)

(* variable lookup *)

(* lookup: variable -> environment -> type_or_value *)

let rec lookup var = function 
    scope::env -> if(List.mem_assoc var scope) then List.assoc var scope else lookup var env
  | [] -> raise (UndeclaredVariable var);;

(* variable declaration *)

(* dec: variable -> type_or_value -> environment -> environment *)

let dec var type_or_value = function
    scope::env -> if(List.mem_assoc var scope) then raise (AlreadyDeclaredVariable var) else ((var,type_or_value)::scope)::env
  | [] -> failwith "assertion error";; (* should never happen *)

(* variable update, only needed for the dynamic semantics *)

(* update uses List.mem_assoc *) 

(* update: variable -> value -> environment -> environment *)

let rec update var value = function
    scope::env -> if(List.mem_assoc var scope) then ((var,value)::scope)::env else scope::update var value env
  | [] -> raise (UndeclaredVariable var);;

(* exit_scope: environment -> environment *)

let exit_scope = function (* removes the innermost scope, only needed for the dynamic semantics *)
    _::env -> env
  | [] -> failwith "assertion error";; (* should never happen *)

(* static semantics of the language *)

(* AST of expressions *)
type exp = Add of exp * exp | Mul of exp * exp | And of exp * exp | Eq of exp * exp | PairLit of exp * exp | Fst of exp | Snd of exp | Sign of exp | Not of exp | IntLiteral of int | BoolLiteral of bool | Var of variable | VectLiteral of exp * exp;;

(* AST of statements and sequence of statements, mutually recursive *)
type
  stmt = AssignStmt of variable * exp | VarStmt of variable * exp | PrintStmt of exp | IfStmt of exp * block * block | ForeachStmt of variable * exp * block 
and
  block = EmptyBlock | Block of stmt_seq
and
  stmt_seq = EmptyStmtSeq | NonEmptyStmtSeq of stmt * stmt_seq;;

(* AST of programs *)
type prog = MyLangProg of stmt_seq;;

(* static types *)

type static_type = IntType | BoolType | PairType of static_type * static_type | VectType;;

(* static errors *)

exception ExpectingStaticType of static_type;;

exception ExpectingPairError of unit;;  

exception ExpectingIntOrVectError of unit;;  

(* static semantic functions *)

(* checkIntOrVect : static_type -> static_type *)

let checkIntOrVect ty = if ty=IntType || ty=VectType then ty else raise (ExpectingIntOrVectError());;

(* 
    typecheckExp : static_env -> exp -> static_type 
*)

(* typecheckExp env exp = ty means that expressions 'exp' is type correct in the environment 'env' and has static type 'ty' *)
   
let rec typecheckExp env=function 
    Add(exp1,exp2) -> let ty=checkIntOrVect(typecheckExp env exp1) in if typecheckExp env exp2=ty then ty else raise (ExpectingStaticType ty)
  | Mul(exp1,exp2) -> let ty1=checkIntOrVect(typecheckExp env exp1) and ty2=checkIntOrVect(typecheckExp env exp2) in if ty1!=ty2 then VectType else IntType
  | And(exp1,exp2) -> if typecheckExp env exp1=BoolType && typecheckExp env exp2=BoolType then BoolType else raise (ExpectingStaticType BoolType)
  | Eq(exp1,exp2) -> let type1=typecheckExp env exp1 in if typecheckExp env exp2=type1 then BoolType else raise (ExpectingStaticType type1)
  | PairLit(exp1,exp2) -> let type1=typecheckExp env exp1 and type2=typecheckExp env exp2 in PairType(type1,type2)
  | Fst exp -> (match typecheckExp env exp with PairType(type1,_) -> type1 | _ -> raise (ExpectingPairError ()))
  | Snd exp -> (match typecheckExp env exp with PairType(_,type2) -> type2 | _ -> raise (ExpectingPairError()))
  | Sign exp -> if typecheckExp env exp=IntType then IntType else raise (ExpectingStaticType IntType)
  | Not exp -> if typecheckExp env exp=BoolType then BoolType else raise (ExpectingStaticType BoolType)
  | IntLiteral _ -> IntType
  | BoolLiteral _ -> BoolType
  | Var var -> lookup var env
  | VectLiteral(exp1,exp2) ->  if typecheckExp env exp1=IntType && typecheckExp env exp2=IntType then VectType else raise (ExpectingStaticType IntType);;

(* mutually recursive functions

 typecheckStmt : static_env -> stmt -> static_env 
 typecheckBlock : static_env -> block -> unit 
 typecheckStmtSeq : static_env -> stmt_seq -> unit

*)

(* typecheckStmt env1 st = env2 means that statement 'st' is type correct in the environment 'env1' and defines the new environment 'env2' *)
(* typecheckBlock env block = () means that the block 'block' is type correct in the environment 'env' *)
(* typecheckStmtSeq env1 stSeq = env2 means that statement sequence 'stSeq' is type correct in the environment 'env1' and defines the new environment 'env2' *)

let rec typecheckStmt env=function
    AssignStmt(var,exp) -> 
      let type1=lookup var env in 
        if typecheckExp env exp=type1 then env else raise (ExpectingStaticType type1)
  | VarStmt(var,exp) -> dec var (typecheckExp env exp) env
  | PrintStmt exp -> let _=typecheckExp env exp in env
  | IfStmt(exp,thenBlock,elseBlock) -> 
      if typecheckExp env exp=BoolType then 
        let _=typecheckBlock env thenBlock and _=typecheckBlock env elseBlock in env 
      else raise (ExpectingStaticType BoolType)
  | ForeachStmt(var,exp,block) ->
    if typecheckExp env exp=VectType then
      let forEnv = dec var IntType (enter_scope env) in let _=typecheckBlock forEnv block in env
    else raise (ExpectingStaticType VectType)
and 
 typecheckBlock env =function
    EmptyBlock -> ()
  | Block stmt_seq -> let _=typecheckStmtSeq (enter_scope env) stmt_seq in ()
and                        
  typecheckStmtSeq env=function 
    EmptyStmtSeq -> ()
  | NonEmptyStmtSeq(stmt,stmt_seq) -> typecheckStmtSeq (typecheckStmt env stmt) stmt_seq;;

(* 
  typecheckProg : prog -> unit 
*)

(* typecheckProg p = () means that program 'p' is well defined with respect to the static semantics *)

let typecheckProg = function MyLangProg stmt_seq -> let _=typecheckStmtSeq initial_env stmt_seq in ();;


(* dynamic semantics of the language *)

(* exceptions *)

exception NegativeVectorDimension of int;;

exception VectorIndexOutOfBounds of int * int;;

(* values *)

type value = IntValue of int | BoolValue of bool | PairValue of value*value | VectValue of int list;;

(* dynamic errors *)

type dynamic_type = Int | Bool | Pair | Vector;;

exception ExpectingDynamicType of dynamic_type;; (* dynamic conversion error *) 

exception VectorsWithDifferentDimension of unit;; (* dynamic conversion error *) 

(* auxiliary functions *)

(* dynamic conversion to int type *)
(* toInt : value -> int *)

let toInt = function
    IntValue i -> i |
    _ -> raise (ExpectingDynamicType Int)

(* dynamic conversion to bool type *)
(* toBool : value -> bool *)

let toBool = function
    BoolValue b -> b |
    _ -> raise (ExpectingDynamicType Bool)

(* toPair : value -> value * value *)
(* dynamic conversion to product  type *)

let toPair = function
    PairValue (e1,e2) -> e1,e2 |
    _ -> raise (ExpectingDynamicType Pair);;

(* toVect : value -> int list *)
(* dynamic conversion to vect  type *)

let toVect = function
    VectValue l -> l |
    _ -> raise (ExpectingDynamicType Vector);;

(* implementation of fst and snd operators *)
(* fst : 'a * 'b -> 'a *)

let fst (v1,_) = v1;;

(* snd : 'a * 'b -> 'b *)

let snd (_,v2) = v2;;

(* conversion to string *)

(* to_string : value -> string *)

let rec to_string = function
    IntValue i -> string_of_int(i) 
  | BoolValue b -> string_of_bool(b) 
  | PairValue(v1,v2) -> "(" ^ to_string v1 ^ "," ^ to_string v2 ^ ")"
  | VectValue l -> "[" ^ String.concat ";" (List.map string_of_int l) ^ "]";;

(* generic_add : value -> value -> value *)
(* addition for both integers and vectors *)

let generic_add val1 val2 = match val1,val2 with
    IntValue n1,IntValue n2 -> IntValue(n1+n2)
  | VectValue l1,VectValue l2 -> if List.length l1!=List.length l2 then raise (VectorsWithDifferentDimension ()) else VectValue(List.rev(List.fold_left2 (fun acc el1 el2 -> el1+el2::acc) [] l1 l2))
  | IntValue _ , _ -> raise (ExpectingDynamicType Int)
  | VectValue _ , _ -> raise (ExpectingDynamicType Vector)
  | _ -> raise (ExpectingIntOrVectError ())

(* generic_mul : value -> value -> value *)
(* multiplication for both integers and vectors *)

let generic_mul val1 val2 = match val1,val2 with
    IntValue n1,IntValue n2 -> IntValue(n1*n2)
  | VectValue l1,VectValue l2 -> if List.length l1!=List.length l2 then raise (VectorsWithDifferentDimension ()) else IntValue(List.fold_left2 (fun acc el1 el2 -> acc+el1*el2) 0 l1 l2)
  | VectValue l,IntValue n | IntValue n,VectValue l -> VectValue(List.map (( * ) n) l) 
  | _ -> raise (ExpectingIntOrVectError ())

(* VectValue(List.fold_left2 (fun acc el1 el2 -> acc+el1*el2) 0 l1 l2) *)
           
(* auxiliary printing function *)

(* println : value -> unit *)

let println value = print_string (to_string value ^ "\n");;


(* evalExp : dynamic_env -> exp -> value *)
(* evalExp env exp = val means that expressions 'exp' successfully evaluates to 'val' in the environment 'env' *)

let rec evalExp env=function 
    Add(exp1,exp2) -> generic_add (evalExp env exp1)  (evalExp env exp2)
  | Mul(exp1,exp2) -> generic_mul (evalExp env exp1)  (evalExp env exp2)
  | And(exp1,exp2) -> BoolValue(toBool(evalExp env exp1)&&toBool(evalExp env exp2))
  | Eq(exp1,exp2) -> BoolValue(evalExp env exp1=evalExp env exp2)
  | PairLit(exp1,exp2) -> PairValue(evalExp env exp1,evalExp env exp2)
  | Fst exp -> fst (toPair(evalExp env exp))
  | Snd exp -> snd (toPair(evalExp env exp))
  | Sign exp -> IntValue(-toInt(evalExp env exp))
  | Not exp -> BoolValue(not (toBool(evalExp env exp)))
  | IntLiteral i -> IntValue i
  | BoolLiteral b -> BoolValue b
  | Var var -> lookup var env
  | VectLiteral(exp1,exp2) ->
    let ind=toInt(evalExp env exp1) and dim=toInt(evalExp env exp2) in
    if dim<0 then raise (NegativeVectorDimension dim)
    else if ind<0 || ind>=dim then raise (VectorIndexOutOfBounds(ind,dim))
    else VectValue(List.init dim (fun i -> if i=ind then 1 else 0));;


(* mutually recursive
   executeStmt : dynamic_env -> stmt -> dynamic_env
   executeBlock : dynamic_env -> block -> dynamic_env
   executeStmtSeq : dynamic_env -> stmt_seq -> dynamic_env
*)

(* executeStmt env1 'stmt' = env2 means that the execution of statement 'stmt' in environment 'env1' successfully returns the new environment 'env2' *)
(* executeBlock env1 block = env2 means that the execution of block 'block' in environment 'env1' successfully returns the new environment 'env2' *)
(* executeStmtSeq env1 stmt_seq = env2 means that the execution of sequence 'stmt_seq' in environment 'env1' successfully returns the new environment 'env2' *)
(* executeStmt, executeBlock and executeStmtSeq write on the standard output if some 'print' statement is executed *)

let rec executeStmt env=function
    AssignStmt(var,exp) -> update var (evalExp env exp) env
  | VarStmt(var,exp) -> dec var (evalExp env exp) env
  | PrintStmt exp -> let _=println (evalExp env exp) in env
  | IfStmt(exp,thenBlock,elseBlock) ->
        if toBool(evalExp env exp) then  
          executeBlock env thenBlock  
        else 
          executeBlock env elseBlock
  | ForeachStmt(var,exp,block) -> let vect = toVect(evalExp env exp) and forEnv = dec var (IntValue 0) (enter_scope env) in (* for variable initialized with 0, any other integer value works as well *)
            exit_scope (List.fold_left (fun env vectElem -> executeBlock (update var (IntValue vectElem) env) block) forEnv vect)
and
  
  executeBlock env=function (* note the differences with the static semantics *)
    EmptyBlock -> env
  | Block stmt_seq -> exit_scope (executeStmtSeq (enter_scope env) stmt_seq)

and 

  executeStmtSeq env=function 
    EmptyStmtSeq -> env 
  | NonEmptyStmtSeq(stmt,stmt_seq) -> executeStmtSeq (executeStmt env stmt) stmt_seq;;

(* executeProg : prog -> unit *)
(* executeProg prog = () means that program 'prog' has been executed successfully, by possibly writing on the standard output *)

let executeProg = function MyLangProg stmt_seq -> let _=executeStmtSeq initial_env stmt_seq in ();;

