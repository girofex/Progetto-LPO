[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-718a45dd9cf7e7f842a935f5ebbe5719a5e09af4491e668f4dbf3b35d5cca122.svg)](https://classroom.github.com/online_ide?assignment_repo_id=11355715&assignment_repo_type=AssignmentRepo)
# Progetto finale LPO a.a. 2023-'23
Il progetto finale consiste nell'implementazione di un'estensione del linguaggio sviluppato durante gli ultimi laboratori Java;
può quindi essere usata come base di partenza la soluzione proposta per l'ultimo laboratorio.

L'interfaccia da linea di comando per interagire con l'interprete è la stessa utilizzata nei laboratori finali:
- il programma da eseguire può essere letto da un file di testo `<filename>` con l’opzione `-i <filename>`, altrimenti viene letto dallo standard
input
- l'output del programma in esecuzione può essere salvato su un file di testo `<filename>` con l’opzione `-o <filename>`, altrimenti viene usato lo standard output
- l’opzione `-ntc` (abbreviazione di no-type-checking) permette di eseguire il programma senza effettuare prima il controllo di semantica statica del
typechecker 

## Definizione del linguaggio

### Sintassi
Il linguaggio contiene le nuove parole chiave `foreach` e `in` e i nuovi simboli `[` e `]`.

La sintassi del linguaggio è definita da questa grammatica in forma EBNF:

```
Prog ::= StmtSeq EOF
StmtSeq ::= Stmt (';' StmtSeq)?
Stmt ::= 'var'? IDENT '=' Exp | 'print' Exp |  'if' '(' Exp ')' Block ('else' Block)? | 'foreach' IDENT 'in' Exp Block
Block ::= '{' StmtSeq '}'
Exp ::= And (',' And)* 
And ::= Eq ('&&' Eq)* 
Eq ::= Add ('==' Add)*
Add ::= Mul ('+' Mul)*
Mul::= Atom ('*' Atom)*
Atom ::= 'fst' Atom | 'snd' Atom | '-' Atom | '!' Atom | BOOL | NUM | IDENT | '(' Exp ')' | '[' Exp ';' Exp ']' 
```
La grammatica **non** richiede trasformazioni e può essere utilizzata così com'è per sviluppare un parser per il linguaggio con un solo token di lookahead.

Rispetto al linguaggio del laboratorio, sono stati aggiunti
- il literal di tipo vector  `'[' Exp ';' Exp ']'`
- lo statement `'foreach' IDENT 'in' Exp Block`

### Semantica statica

La semantica statica è definita in OCaml nella prima parte del file `semantica.ml`; è utile consultare anche gli esempi nel folder `test`. Il nuovo tipo `vector` corrisponde a vettori di interi costruiti a partire dai literal `'[' Exp ';' Exp ']'` e dagli operatori `'+'` e `'*'`.

#### Regole della semantica statica
- il literal `'[' Exp1 ';' Exp2 ']'` è corretto e ha tipo `vector` se `Exp1` e `Exp2` hanno tipo `int`
- l'espressione `Exp1 '+' Exp2` è corretta e ha tipo `int` se `Exp1` e `Exp2` hanno tipo `int`
- l'espressione `Exp1 '+' Exp2` è corretta e ha tipo `vector` se `Exp1` e `Exp2` hanno tipo `vector`
- l'espressione `Exp1 '*' Exp2` è corretta e ha tipo `int` se `Exp1` e `Exp2` hanno tipo `int`
- l'espressione `Exp1 '*' Exp2` è corretta e ha tipo `int` se `Exp1` e `Exp2` hanno tipo `vector`
- l'espressione `Exp1 '*' Exp2` è corretta e ha tipo `vector` se `Exp1` ha tipo `int`e `Exp2` ha tipo `vector` oppure `Exp1` ha tipo `vector`e `Exp2` ha tipo `int`
- lo statement `'foreach' IDENT 'in' Exp Block` è corretto se `Exp` ha tipo `vector` rispetto all'ambiente corrente `env` e `Block` è corretto rispetto all'ambiente ottenuto aggiungendo a `env` un nuovo scope annidato dove l'unica variabile dichiarata è `IDENT` di tipo `int`.

### Semantica dinamica
La semantica dinamica è definita in OCaml nella seconda parte del file `semantica.ml`; è utile consultare anche gli esempi nel folder `test`.

#### Regole della semantica dinamica

- se `Exp1` e `Exp2` si valutano negli interi `ind` e `dim`, allora `'[' Exp1 ';' Exp2 ']'` si valuta nel vettore di dimensione `dim` che contiene 1 in corrispondenza dell'indice `ind` e 0 nelle altre posizioni. Gli indici iniziano da 0, viene sollevata un'eccezione se `dim` è negativo, oppure `ind` non  è maggiore o uguale di 0 e minore di `dim`.

Esempio
```
print [3;5]
```
stampa
```
[0;0;0;1;0]
```
- se `Exp1` e `Exp2` si valutano negli interi `i1` e `i2`, allora `Exp1'+'Exp2` si valuta nell'intero `i1+i2`
- se `Exp1` e `Exp2` si valutano nei vettori `v1` e `v2`, allora `Exp1'+'Exp2` si valuta nel vettore `v1+v2`; viene sollevata un'eccezione se i due vettori non hanno la stessa dimensione. La somma di vettori è definita da
```
[a_0;...;a_n]+[b_0;...;b_n]=[a_0+b_0;...;a_n+b_n]
```
- se `Exp1` e `Exp2` si valutano negli interi `i1` e `i2`, allora `Exp1'*'Exp2` si valuta nell'intero `i1*i2`
- se `Exp1` e `Exp2` si valutano nei vettori `v1` e `v2`, allora `Exp1'*'Exp2` si valuta nell'intero ottenuto dal prodotto scalare di `v1` e` v2`; viene sollevata un'eccezione se i due vettori non hanno la stessa dimensione. Il prodotto scalare di vettori è definito da
```
[a_0;...;a_n]*[b_0;...;b_n]=a_0*b_0+...+a_n*b_n
```
- se `Exp1` e `Exp2` si valutano in un intero `i` e in un vettore `v`, o viceversa, allora `Exp1'*'Exp2` si valuta nel vettore ottenuto dal prodotto misto tra `i` e `v`. Il prodotto misto tra un intero e un vettore è definito da
```
i*[a_0;...;a_n]=[a_0;...;a_n]*i= [i*a_0;...;i*a_n]
```
- l'esecuzione dello statement `'foreach' IDENT 'in' Exp Block` consiste nella valutazione dell'espressione `Exp` rispetto all'ambiente corrente `env`;
deve essere restituito un vettore `v` sui cui elementi viene iterata l'esecuzione di `Block` rispetto a un ambiente ottenuto da `env` aggiungendo uno scope annidato contenente la sola variabile `IDENT` alla quale viene assegnato a ogni iterazione un elemento di `v` in ordine dall'indice minimo al massimo. Inizialmente la variabile  `IDENT` viene inizializzata con un valore intero arbitrario. 

Esempio:
```
foreach i in [0;3]+2*[1;3]+3*[2;3]{print i}
```
stampa
```
1
2
3
```
**Importante**:
- i valori di tipo vector sono stampabili e vengono visualizzati mediante la notazione [a_0;...;a_n]
- due vettori sono uguali se e solo se hanno la stessa dimensione e gli stessi elementi in corrispondenza degli stessi indici
```
[a_0;...;a_n]=[b_0;...;b_m] se e solo se n=m e a_i=b_i per ogni i=1..n
```
- per implementare l'esecuzione dello statement `foreach` conviene usare il corrispondente statement Java evitando la ricorsione

## Contenuto del repository

* `semantica.ml` : semantica statica e dinamica del linguaggio esteso, definita in OCaml
* `tests/success`: test corretti anche **senza** l'opzione `-ntc`
* `tests/failure/syntax`: test con errori di sintassi 
* `tests/failure/static-semantics`: test con errori statici **senza** l'opzione `-ntc` ed errori dinamici **con** l'opzione `-ntc`
* `tests/failure/static-semantics-only`: test con errori statici **senza** l'opzione `-ntc` e corretti con l'opzione `-ntc`
* `tests/failure/dynamic-semantics`: test che generano errori dinamici **con** o **senza** l'opzione `-ntc`

## Modalità di consegna

- La consegna è valida solo se il **progetto passa tutti i test** contenuti nel folder `tests`; la valutazione del progetto tiene conto dell'esecuzione di test aggiuntivi e della qualità del codice
- Le scadenze dei turni di consegna coincidono con le date delle prove scritte; dopo ogni scadenza, vengono corretti tutti i progetti consegnati e pubblicati i relativi risultati prima che le consegne siano riaperte. **Dopo la data dell'ultima prova scritta dell'appello invernale non è più possibile consegnare progetti validi per l'anno accademico in corso**
- Il progetto può essere consegnato anche se l'esame scritto non è stato ancora superato
- Dopo il commit (e push) finale del progetto su GitHub, la consegna va segnalata da **un singolo componente del gruppo** utilizzando [AulaWeb](https://2022.aulaweb.unige.it/mod/assign/view.php?id=51610) e indicando **il numero del gruppo** definito nell'[elenco su AulaWeb](https://2022.aulaweb.unige.it/mod/wiki/view.php?id=51608)
- Per ricevere supporto durante lo sviluppo del progetto è consigliabile tenere sempre aggiornato il codice del progetto sul repository GitHub  
- Dopo che il progetto è stato valutato positivamente, il relativo colloquio **individuale** può essere sostenuto  anche se l'esame scritto non è stato ancora superato; esso ha lo scopo di verificare che ogni componente del gruppo abbia compreso il funzionamento del codice e abbia contribuito attivamente al suo sviluppo
- Per ulteriori informazioni consultare la [pagina AulaWeb sulle modalità di esame](https://2022.aulaweb.unige.it/mod/page/view.php?id=51601)
