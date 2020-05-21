/**
 * Ejemplo mi primer proyecto con Jison utilizando Nodejs en Ubuntu
 */

/* Definición Léxica */
%lex

%options case-insensitive

%%

\s+    //se ignoran espacios en blanco
"//".*   //se ignoran comentarios de una linea
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]   //comentario multilinea

/* palabras reservadas*/

"int"				return 'RINT';
"String"			return 'RSTRING';
"boolean"			return 'RBOOLEAN';
"char"				return 'RCHAR';
"double"			return 'RDOUBLE';
"void"				return 'RVOID';
"main"				return 'RMAIN';
"class"				return 'RCLASS';
"if"				return 'RIF';
"else"				return 'RELSE';
"for"				return 'RFOR';
"break"				return 'RBREAK';
"System"			return 'RSYSTEM';
"out"				return 'ROUT';
"print"				return 'RPRINT';
"import" 			return 'RIMPORT';
"while"				return 'RWHILE';
"switch"			return 'RSWITCH';
"do"				return 'RDO';
"break"				return 'RBREAK';
"return"			return 'RTURN';
"case"				return 'RCASE';
"default"			return 'RDEFAULT';
"continue"			return 'RCONTINUE';


"Evaluar"           return 'REVALUAR';
"."					return 'PUNTO';
";"                 return 'PTCOMA';
","					return 'COMA';
"("                 return 'PARIZQ';
")"                 return 'PARDER';
"["                 return 'CORIZQ';
"]"                 return 'CORDER';
":"					return 'DOSPTS';
"{"					return 'LLAVIZQ';
"}"					return 'LLAVDER';

/*OPERACIONES*/

"+"                 return 'MAS';
"-"                 return 'MENOS';
"*"                 return 'POR';
"/"                 return 'DIVIDIDO';
"^"					return 'POTENCIA';

/*COMBINADAS*/
"+="				return 'O_MAS';
"-="				return 'O_MENOS';
"*="				return 'O_POR';
"/="				return 'O_DIVIDIDO';
"&&"				return 'AND';
"||"				return 'OR';

/*CONDICIONALES COMPUESTAS*/

"<="				return 'MENIGQUE';
">="				return 'MAYIGQUE';
"=="				return 'DOBLEIG';
"!="				return 'NOIG';
"<"					return 'MENQUE';
">"					return 'MAYQUE';
"="					return 'IGUAL';
"!"					return 'NOT';



/* Espacios en blanco */
[ \r\t]+            {}
\n                  {}

\"[^\"]*\"				return 'CADENA';
[0-9]+"."[0-9]+    return 'DECIMAL';
[0-9]+                return 'ENTERO';
([a-zA-Z])[a-zA-z0-9_]* return 'IDENTIFICADOR';

[\t\r\n\f] %{/*se ignoran*/%}

<<EOF>>                 return 'EOF';

.                       { console.error('Este es un error léxico: ' + yytext + ', en la linea: ' + yylloc.first_line + ', en la columna: ' + yylloc.first_column); }
/lex

/*IMPORT PARA EL DOCUMENTO instrucciones.js DONDE SE ENCUENTRA LAS CONSTANTES QUE RETORNAN DATOS PARA EL AST*/

%{
	const TIPO_OPEACION = require('./instrucciones').Tipo_Operacion;
	const TIPO_VALOR = require('./instrucciones').Tipo_Dato;
	const instruccionesAPI = require('./instrucciones').instruccionesAPI;
%}

/* Asociación de operadores y precedencia */

%left 'MAS' 'MENOS'
%left 'POR' 'DIVIDIDO'
%left UMENOS

%start ini

%% /* Definición de la gramática */

ini
	: instrucciones EOF{
		return $1;			/* se retorna el ast el cual jala haciendo node parser en ese documento esta la carga*/
	}
;

instrucciones
	: instrucciones instruccion		{$1.push($2);$$=$1;}	/*esto guarda datos para retornarlos*/
	| instruccion					{$$=[$1];}
;



instruccion
	: RVOID RMAIN PARIZQ PARDER LLAVIZQ instruccion LLAVDER	{$$=instruccionesAPI.nuevoMain($6);}	
	| RCLASS IDENTIFICADOR LLAVIZQ instruccion LLAVDER		{$$=instruccionesAPI.nuevoClass($2,$4);}
	| RINT IDENTIFICADOR lista_decla PTCOMA instruccion    {$$=instruccionesAPI.nuevoDeclaracion($2,TIPO_VALOR.Tipo_Int);}
	| RSTRING IDENTIFICADOR lista_decla PTCOMA instruccion  {$$=instruccionesAPI.nuevoDeclaracion($2,TIPO_VALOR.Tipo_String);}
	| RDOUBLE IDENTIFICADOR lista_decla PTCOMA instruccion	{$$=instruccionesAPI.nuevoDeclaracion($2,TIPO_VALOR.Tipo_Double);}
	| RCHAR IDENTIFICADOR lista_decla PTCOMA instruccion 	{$$=instruccionesAPI.nuevoDeclaracion($2,TIPO_VALOR.Tipo_Char);}
	| RBOOLEAN IDENTIFICADOR lista_decla PTCOMA instruccion	{$$=instruccionesAPI.nuevoDeclaracion($2,TIPO_VALOR.Tipo_Boolean);}
	| IDENTIFICADOR lista_decla PTCOMA instruccion			
	| RIMPORT IDENTIFICADOR PTCOMA instruccion				
	| RSYSTEM PUNTO ROUT PUNTO RPRINT PARIZQ valor PARDER PTCOMA instruccion	{$$=instruccionesAPI.nuevoImprimir($7);}
	| RIF PARIZQ condicion PARDER LLAVIZQ instruccion LLAVDER else instruccion
	| RSWITCH PARIZQ valor PARDER LLAVIZQ casos faltantes LLAVDER instruccion
	| RFOR PARIZQ dec PTCOMA condicion PTCOMA valor incremento PARDER LLAVIZQ instruccion lista_ciclos LLAVDER instruccion
	| RWHILE PARIZQ condicion PARDER LLAVIZQ instruccion lista_ciclos LLAVDER instruccion
	| RDO LLAVIZQ instruccion lista_ciclos LLAVDER RWHILE PARIZQ condicion PARDER PTCOMA instruccion
	|
;

lista_decla
	: COMA IDENTIFICADOR lista_decla
	| IGUAL valor otra_declaracion
	| 
;

otra_declaracion
	: COMA IDENTIFICADOR lista_decla
	| 
;

valor
	: IDENTIFICADOR agregar mul_div suma_resta
	| ENTERO  operacion 
	| DECIMAL operacion
	| CADENA agregar
	| PARIZQ compuesto PARDER
;

agregar
	: MAS valor agregar
	| PARIZQ valor llamado PARDER
	| POTENCIA
	| 
;

llamado
	: COMA valor
	| 
;

operacion
	: ter suma_resta
;

suma_resta
	: MAS ter suma_resta
	| MENOS ter suma_resta
	| 
;

ter
	: terminal mul_div
;

mul_div
	: POR terminal mul_div
	| DIVIDIDO terminal mul_div
	| 
;

terminal
	: PARIZQ  operacion PARDER elevado
	| ENTERO elevado
	| DECIMAL elevado
	| IDENTIFICADOR elevado
	| 
;
compuesto
	: ENTERO compuesto
	| MAYQUE compuesto
	| MENQUE compuesto
	|
	
;
elevado
	: POTENCIA
	|
;
condicion
	: diferente valor operador valor comparadores
;

operador
	: IGUAL
	| DOBLEIG
	| MAYQUE
	| MENQUE
	| MAYIGQUE
	| MENIGQUE
	| NOIG
;

comparadores
	: AND condicion
	| OR condicion
	| 
;

diferente
	: NOT
	| 
;

else 
	: RELSE anidado cuerel
	| 
;

cuerel
	:  LLAVIZQ instruccion LLAVDER
	|
;

anidado
	: RIF PARIZQ condicion PARDER LLAVIZQ instruccion LLAVDER else
	| 
;

casos
	: RCASE valor DOSPTS instruccion detener PTCOMA casos
	|
;

faltantes
	: RDEFAULT DOSPTS instruccion detener PTCOMA
	|
;

detener
	: RBREAK
	|
;

dec
	: sel_tipo IDENTIFICADOR IGUAL valor 
;

sel_tipo
	: RINT
	| RSTRING
	| RDOUBLE
	| RBOOLEAN
	| RCHAR
	| 
;

incremento
	: MAS MAS
	| MENOS MENOS
;

lista_ciclos
	: RBREAK PTCOMA
	| RCONTINUE PTCOMA
	| 
;




