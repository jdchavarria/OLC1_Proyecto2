/**
 * Ejemplo mi primer proyecto con Jison utilizando Nodejs en Ubuntu
 */

/* Definición Léxica */
%lex
%options case-sensitive
%option yylineno
%locations
%%

\s+    //se ignoran espacios en blanco
"//".*   //se ignoran comentarios de una linea
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]   //comentario multilinea

/* palabras reservadas*/

"int"				return 'Int';
"String"			return 'String';
"boolean"			return 'Boolean';
"char"				return 'Char';
"double"			return 'Double';
"void"				return 'Void';
"main"				return 'Main';
"class"				return 'Class';
"if"				return 'If';
"else"				return 'Else';
"for"				return 'For';
"break"				return 'Break';
"System"			return 'System';
"out"				return 'Out';
"print"				return 'Print';
"println"		    return 'Println';
"import" 			return 'Import';
"while"				return 'While';
"switch"			return 'Switch';
"do"				return 'Do';
"break"				return 'Break';
"return"			return 'Return';
"case"				return 'Case';
"default"			return 'Default';
"continue"			return 'Continue';
"public"            return 'Public';
"private"           return 'Private';
"protected"         return 'Protected';
"static"            return 'Static';
"true"              return 'True';
"false"             return 'False';

"Evaluar"           return 'Evaluar';
"."					return 'Punto';
";"                 return 'PuntoComa';
","					return 'Coma';
"("                 return 'ParApertura';
")"                 return 'ParCierre';
"["                 return 'CorApertura';
"]"                 return 'CorCierre';
":"					return 'DosPuntos';
"{"					return 'LlaveApertura';
"}"					return 'LlaveCierre';

/*OPERACIONES*/

"+"                 return 'Mas';
"-"                 return 'Menos';
"*"                 return 'Por';
"/"                 return 'Divicion';
"^"					return 'Potencia';
"%"					return 'Modulo';

/*COMBINADAS*/
"+="				return 'O_MAS';
"-="				return 'O_MENOS';
"*="				return 'O_POR';
"/="				return 'O_DIVIDIDO';
"&&"				return 'And';
"||"				return 'Or';

/*CONDICIONALES COMPUESTAS*/

"<="				return 'MenorIgual';
">="				return 'MayorIgual';
"=="				return 'DobleIgual';
"!="				return 'NoIgual';
"<"					return 'MenorQue';
">"					return 'MayorQue';
"="					return 'Igual';
"!"					return 'Not';

/*TOKENS */
\"[^\"]*\"				    return 'Cadena';
\'[^]\'				        return 'Caracter';
[0-9]+"."[0-9]+             return 'Decimal';
[0-9]+                      return 'Entero';
([a-zA-Z])[a-zA-z0-9_]*     return 'Identificador';


/* Espacios en blanco */
[ \r\t]+            {}
\n                  {}

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

%left Mas Menos
%left Por Divicion Modulo
%left Potencia 

%start init

%% /* Definición de la gramática */

init
	: INICIO EOF{
		return $1;			/* se retorna el ast el cual jala haciendo node parser en ese documento esta la carga*/
	}
;

INICIO           
    : MOD_ACCESO Class Identificador LlaveApertura BODY_CLASS  LlaveCierre  INICIO
    | λ
;

MOD_ACCESO
    : Public
    | Private
    | Protected
    |
;

TIPO_DATO
    : Int
    | String
    | Boolean
    | Char
    | Double
;

STATIC 
    : Static
    | 
;
        
BODY_CLASS
    : MOD_ACCESO STATIC TIPO_RETORNO BODY_CLASS
    |
; 

TIPO_RETORNO
    : TIPO_DATO METODO_VARIABLE
    | Void <tipo_metodo>
;

METODO_VARIABLE
    : Main ParApertura  MAIN_PARAM ParCierre LlaveApertura  BODY LlaveCierre
    | Identificador PARAM_ASIGN
;

PARAM_ASIGN
    : ParApertura  PARAMETROS  ParCierre LlaveApertura  BODY LlaveCierre
    | DEC_ASIGN PuntoComa
;

/*  ##############################   METODOS  ########################## */

TIPO_METODO
    : Main  ParApertura MAIN_PARAM ParCierre LlaveApertura BODY LlaveCierre
    | Identificador ParApertura PARAMETROS ParCierre LlaveApertura BODY LlaveCierre
;

MAIN_PARAM
    : String CorApertura CorCierre Identificador
    |
; 

PARAMETROS 
    : TIPO_DATO Identificador OTRO_PARAMETRO
    | 
;

OTRO_PARAMETRO
    : Coma TIPO_DATO Identificador OTRO_PARAMETRO
    | 
;

RETORNO 
    : Return VALOR_RETORNO PuntoComa
;

VALOR_RETORNO 
    : VALOR
    | 
;

CONTINUE 
    : Continue PuntoComa
    |
;

BODY 
    : DECLARACION BODY
    | ASIGNACION BODY
    | IMPRIMIR BODY
    | IF BODY
    | SWITCH BODY
    | FOR BODY
    | WHILE BODY
    | DO_WHILE BODY
    | RETORNO BODY
    | CONTINUE  BODY
    | 
;


/*  ##############################   VARIABLES  ########################## */
/* ---------------- Declaracion de variables y asignacion  --------- */
DECLARACION 
    : TIPO_DATO Identificador DEC_ASIGN PuntoComa
;

DEC_ASIGN
    : Coma Identificador DEC_ASIGN
    | Igual VALOR OTRA_DECLARACION
    |
; 

OTRA_DECLARACION
    : Coma Identificador DEC_ASIGN 
	|  λ
;

/* ---------------- Asignacion de variables ------------------------  */
ASIGNACION
    : Identificador Igual  VALOR PuntoComa
;

/* ---------------- Valores de variables --------------------------- */
VALOR
    : OPERACION 
    | Cadena CONCATENAR
    | Caracter 
    | True
    | False 
;

VARIABLE
    : Identificador <concatenar>//variable tipo cadena (string)
    | OPERACION //variable tipo numerico (int, float, double)
;

/* ---------------- Operaciones numericas --------------------------  */
CONCATENAR
    : Mas  VALOR  CONCATENAR
    | 
;

/*  ##############################   OPERACION  ########################## */

OPERACION
    : T SUM_RES
;

SUM_RES
    : Mas T SUM_RES
    | Menos T SUM_RES
    |
;

T
    : NUMERO MUL_DIV
;

MUL_DIV
    : Por NUMERO MUL_DIV
    | Divicion NUMERO MUL_DIV
    |
;

NUMERO 
    : ParApertura OPERACION ParCierre 
    | Decimal 
    | Entero
    | Identificador
;


/*  ##############################   IMPRIMIR POR CONSOLA  ########################## */
IMPRIMIR
    : System Punto Out Punto METODO_IMPRIMIR ParApertura VALOR OTRO_VALOR ParCierre PuntoComa
;

METODO_IMPRIMIR
    : Print 
    | Println
;

OTRO_VALOR
    : Mas  VALOR OTRO_VALOR
    |
;


/*  ##############################   SENTENCIA IF   ########################## */
IF
    :                  'if' ( <condicion> ) { <body> } <else_if>
;

ELSE_IF
    : Else ELSE_IF_BODY 
	|
; 
                        
ELSE_IF_BODY
    : If ParApertura CONDICION ParCierre LlaveApertura BODY LlaveCierre ELSE_IF
    | LlaveApertura BODY LlaveCierre 
;

/*  ##############################   CONDICION   ########################## */

CONDICION
    : EXPRESION OPERADOR
;

OPERADOR
    : And EXPRESION OPERADOR
    | Or EXPRESION OPERADOR
    |
;

EXPRESION 
    : Not NEGAR_EXPRESION
    | ParApertura VALOR EXP_PAREN                        
    | VALOR COMPARADOR
;

EXP_PAREN
    : COMPARADOR ParCierre
    | ParCierre COMPARADOR
;

NEGAR_EXPRESION
    :  ParApertura VALOR COMPARADOR OPERADOR ParCierre
    | VALOR
    |  Not NEGAR_EXPRESION
;

COMPARADOR 
    : MenorQue VALOR
    | MayorQue VALOR
    | DobleIgual VALOR
    | MenorIgual VALOR
    | MayorIgual VALOR
    | NoIgual VALOR
    | 
;

/*  ##############################   SWITCH   ########################## */
SWITCH
    : Switch ParApertura VALOR ParCierre LlaveApertura CASE DEFAULT LlaveCierre 
;

CASE
    : Case  VALOR DosPuntos BODY Break PuntoComa CASE
    |
;

DEFAULT
    : Default  DosPuntos BODY Break PuntoComa 
    |
; 

/*  ##############################   FOR   ########################## */
FOR
    : For ParApertura DEC PuntoComa COND_FOR PuntoComa Identificador INCREMENTO ParCierre LlaveApertura BODY LlaveCierre
;

COND_FOR
    : VALOR COMP_FOR VALOR
;  

COMP_FOR
    : MenorQue VALOR
    | MayorQue VALOR
    | DobleIgual VALOR
    | MenorIgual VALOR
    | MayorIgual VALOR
    | NoIgual VALOR 
;

DEC
    : TIPO_DATO Identificador Igual VALOR 
    | Identificador Igual VALOR
;

INCREMENTO
    : Mas Mas 
    | Menos Menos
;

/*  ##############################   WHILE   ########################## */
WHILE
    : While ParApertura CONDICION ParCierre LlaveApertura BODY LlaveCierre
;

/*  ##############################   DO WHILE   ########################## */

DO_WHILE 
    : Do LlaveApertura BODY LlaveCierre While ParApertura CONDICION ParCierre PuntoComa
;

