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
	const TIPO_OPERACION = require('./instrucciones').Tipo_Operacion;
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
	: RVOID RMAIN PARIZQ PARDER LLAVIZQ instrucciones LLAVDER instrucciones	{$$=instruccionesAPI.nuevoMain($6);}	
	| RCLASS IDENTIFICADOR LLAVIZQ instrucciones LLAVDER  instrucciones		{$$=instruccionesAPI.nuevoClass($2,$4);}
	| RINT IDENTIFICADOR  PTCOMA  instrucciones  {$$=instruccionesAPI.nuevoDeclaracion($2,TIPO_VALOR.Tipo_Int);}
	| RSTRING IDENTIFICADOR  PTCOMA instrucciones  {$$=instruccionesAPI.nuevoDeclaracion($2,TIPO_VALOR.Tipo_String);}
	| RDOUBLE IDENTIFICADOR  PTCOMA instruccion	{$$=instruccionesAPI.nuevoDeclaracion($2,TIPO_VALOR.Tipo_Double);}
	| RCHAR IDENTIFICADOR PTCOMA instruccion 	{$$=instruccionesAPI.nuevoDeclaracion($2,TIPO_VALOR.Tipo_Char);}
	| RBOOLEAN IDENTIFICADOR  PTCOMA instruccion	{$$=instruccionesAPI.nuevoDeclaracion($2,TIPO_VALOR.Tipo_Boolean);}
	| IDENTIFICADOR PTCOMA instruccion			
	| RIMPORT IDENTIFICADOR PTCOMA instruccion 				{$$=instruccionesAPI.nuevoImport($2);}
	| RSYSTEM PUNTO ROUT PUNTO RPRINT PARIZQ expresion_cadena PARDER PTCOMA	instrucciones {$$=instruccionesAPI.nuevoImprimir($7);}
	| RIF PARIZQ expresion_logica PARDER LLAVIZQ instruccion LLAVDER instrucciones  {$$=instruccionesAPI.nuevoIf($3, $6);}
	| RSWITCH PARIZQ expresion_numerica PARDER LLAVIZQ casos  LLAVDER instruccion	{$$=instruccionesAPI.nuevoSwitch($3, $6);}
	| RFOR PARIZQ IDENTIFICADOR IGUAL expresion_numerica PTCOMA expresion_logica PTCOMA IDENTIFICADOR MAS MAS PARDER LLAVIZQ instruccion LLAVDER instruccion	{$$=instruccionesAPI.nuevoPara($3,$5,$7,$9,$14);}
	| RWHILE PARIZQ expresion_logica PARDER LLAVIZQ instruccion  LLAVDER instruccion	{$$=instruccionesAPI.nuevoMientras($3, $6);}
	| RDO LLAVIZQ instruccion LLAVDER RWHILE PARIZQ expresion_logica PARDER PTCOMA instruccion
	|
;

casos
	: casos caso_evaluar
	{
		$1.push($2);
		$$=$1;
	}
	| caso_evaluar	{$$=instruccionesAPI.nuevoListaCasos($1);}
;

caso_evaluar
	: RCASE expresion_numerica DOSPTS instruccion
	{$$=instruccionesAPI.nuevoCaso($2,$4);}
	| RDEFAULT DOSPTS instruccion
	{$$=instruccionesAPI.nuevoCasoDef($3);}
;

operadores
	: O_MAS	{$$=instruccionesAPI.nuevoOperador(TIPO_OPERACION.SUMA);}
	| O_MENOS	{$$=instruccionesAPI.nuevoOperador(TIPO_OPERACION.RESTA);}
	| O_POR		{$$=instruccionesAPI.nuevoOperador(TIPO_OPERACION.MULTIPLICACION);}
	| O_DIVIDIDO	{$$=instruccionesAPI.nuevoOperador(TIPO_OPERACION.DIVISION);}
;
expresion_numerica
	: expresion_numerica MAS expresion_numerica		{$$=instruccionesAPI.nuevoOperacionBinaria($1,$3,TIPO_OPERACION.SUMA);}
	| expresion_numerica MENOS expresion_numerica	{$$=instruccionesAPI.nuevoOperacionBinaria($1,$3,TIPO_OPERACION.RESTA);}
	| expresion_numerica POR expresion_numerica		{$$=instruccionesAPI.nuevoOperacionBinaria($1,$3,TIPO_OPERACION.MULTIPLICACION);}
	| expresion_numerica DIVIDIDO expresion_numerica	{$$=instruccionesAPI.nuevoOperacionBinaria($1,$3,TIPO_OPERACION.DIVISION);}
	| PARIZQ expresion_numerica PARDER		{$$=$2;}
	| ENTERO				{$$=instruccionesAPI.nuevoValor(Number($1),TIPO_VALOR.Tipo_Int);}
	| DECIMAL				{$$=instruccionesAPI.nuevoValor(Number($1),TIPO_VALOR.Tipo_Double);}
	| IDENTIFICADOR			{$$=instruccionesAPI.nuevoValor($1,TIPO_VALOR.Tipo_String);}
	| CADENA				{$$=instruccionesAPI.nuevoValor($1,TIPO_VALOR.Tipo_String);}
	| expresion_relacional {$$=$1;}
;

expresion_cadena
	: expresion_cadena MAS expresion_cadena	{$$=instruccionesAPI.nuevoOperacionBinaria($1,$3,TIPO_OPERACION.CONCATENACION);}
	| CADENA								{$$=instruccionesAPI.nuevoValor($1,TIPO_VALOR.Tipo_String);}
	| expresion_numerica					{$$=$1;}
;

expresion_relacional
	: expresion_numerica MAYQUE expresion_numerica		{ $$ = instruccionesAPI.nuevoOperacionBinaria($1, $3, TIPO_OPERACION.MAYOR_QUE); }
	| expresion_numerica MENQUE expresion_numerica		{ $$ = instruccionesAPI.nuevoOperacionBinaria($1, $3, TIPO_OPERACION.MENOR_QUE); }
	| expresion_numerica MAYIGQUE expresion_numerica	{ $$ = instruccionesAPI.nuevoOperacionBinaria($1, $3, TIPO_OPERACION.MAYOR_IGUAL); }
	| expresion_numerica MENIGQUE expresion_numerica	{ $$ = instruccionesAPI.nuevoOperacionBinaria($1, $3, TIPO_OPERACION.MENOR_IGUAL); }
	| expresion_cadena DOBLEIG expresion_cadena			{ $$ = instruccionesAPI.nuevoOperacionBinaria($1, $3, TIPO_OPERACION.DOBLE_IGUAL); }
	| expresion_cadena NOIG expresion_cadena			{ $$ = instruccionesAPI.nuevoOperacionBinaria($1, $3, TIPO_OPERACION.NO_IGUAL); }
;

expresion_logica
	: expresion_relacional AND expresion_relacional		{ $$ = instruccionesAPI.nuevoOperacionBinaria($1, $3, TIPO_OPERACION.AND);}
	| expresion_relacional OR expresion_relacional		{ $$ = instruccionesAPI.nuevoOperacionBinaria($1, $3, TIPO_OPERACION.OR);}
	| NOT expresion_relacional			{$$=instruccionesAPI.nuevoOperacionUnaria($2,TIPO_OPERACION.NOT);}
	| expresion_relacional				{$$=$1;}
;






