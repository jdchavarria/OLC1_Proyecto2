// Modelos y varbiables
%{
      const { Error } = require('../modelos/Error');

      var idError = 1;
      var lineaError = 0; // Para los errores con los return, break, continue
      var columnaError = 0; // Para los errores con los return, break, continue
      var listaErrores = [];

      var returnExpresion = false; // Retorno de expresiones en funciones o metodos con tipo
      var returnSetencia = false; // Retorno obligatorio

      var contadorBreak = 0; // Auxiliar para saber si un break esta dentro de un ciclo
      var contadorContinue = 0; // Auxiliar para saber si un continue esta dentro de un ciclo
%}

/* Análisis Lexico */
%lex
%options case-sensitive
// Expresiones regulares para ciertos patrones
comentarios             (\/\*[\s\S]*?\*\/|\/\/.*)
identificador           (([a-zA-Z_])[a-zA-Z0-9_]*)
digito                  ([0-9]+)
decimal                 ({digito}("."{digito})?)
comillaSimple           ("'")
comillaDoble            ("\"")
caracter                ({comillaSimple}((?:\\("n"|"t"|"r"|"\\"|"\""|"\'")|(?:(?!{comillaSimple}).))?){comillaSimple})
cadena                  ({comillaDoble}((?:\\{comillaDoble}|(?:(?!{comillaDoble}).))*){comillaDoble})

%%
/* Tokens */
\s+                     /* omitir espacios en blanco */
{comentarios}           /* omitir comentarios */

// Patron               // Nombre Token
"{"                     return '{'
"}"                     return '}'
"("                     return '('
")"                     return ')'
","                     return ','
"."                     return '.'
":"                     return ':'
";"                     return ';'

"boolean"               return 'boolean'
"break"                 return 'break'
"case"                  return 'case'
"char"                  return 'char'
"class"                 return 'class'
"continue"              return 'continue'
"default"               return 'default'
"do"                    return 'do'
"double"                return 'double'
"else"                  return 'else'
"false"                 return 'false'
"for"                   return 'for'
"if"                    return 'if'
"import"                return 'import'
"int"                   return 'int'
"out"                   return 'out'
"System.out.print"      return 'print'
"System.out.println"    return 'println'
"return"                return 'return'
"String"                return 'String'
"switch"                return 'switch'
"System"                return 'System'
"true"                  return 'true'
"void"                  return 'void'
"while"                 return 'while'

"<="                    return '<='
"<"                     return '<'
"=="                    return '=='
">="                    return '>='
">"                     return '>'
"!="                    return '!='
"||"                    return '||'
"&&"                    return '&&'
"!"                     return '!'
"="                     return '='
"++"                    return '++'
"+"                     return '+'
"--"                    return '--'
"-"                     return '-'
"*"                     return '*'
"/"                     return '/'
"^"                     return '^'
"%"                     return '%'
{identificador}         return 'identificador'
{decimal}               return 'decimal'
{caracter}              { yytext = yytext.substr(1,yyleng-2); return 'caracter'; }
{cadena}                { yytext = yytext.substr(1,yyleng-2); return 'cadena'; }
<<EOF>>                 return 'EOF'; // Token fin de archivo

//Mensaje y recuperacion de errores lexicos
.                       { listaErrores.push(new Error(idError, 'Error Lexico', yylloc.first_line, yylloc.first_column, 'Caracter desconocido: ' + yytext)); console.error('Error Lexico: ' + yytext + ' en la linea ' + yylloc.first_line + ' y columna ' + yylloc.first_column); idError++; }
/lex

/* Precedencia de operaciones */
%left '||'                          // Menor Precedencia
%left '&&'
%left '==', '!='
%left '>=', '<=', '<', '>'
%left '+' '-'
%left '*' '/' '%'
%left '^'
%right '!'
%left UMENOS
%right '++' '--'                    // Mayor Precedencia

/* Analisis sintactico */
%start INICIO
%%

// $$     $1      $2    $3
INICIO : IMPORTS CLASS 'EOF'      { if (listaErrores.length > 0) { let eL = []; eL = eL.concat(listaErrores); listaErrores = []; idError = 0; return { 'error': eL }; } return { 'imports': $1, 'class': $2 } }
       | CLASS 'EOF'              { if (listaErrores.length > 0) { let eL = []; eL = eL.concat(listaErrores); listaErrores = []; idError = 0; return { 'error': eL }; } return { 'class': $1 } }
       | 'EOF'
       | error                    { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
       ;

IMPORTS : IMPORTS IMPORT    { $1.push($2); $$ = $1; }
        | IMPORT            { $$ = [$1]; }
        ;

IMPORT : 'import' 'identificador' ';'     { $$ = { 'import': $2 }; }
       | 'import' error                   { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
       ;

CLASS : 'class' 'identificador' '{' CUERPOCLASE '}'         { $$ = { 'nombreClase': $2, 'contenidoClase': $4 }; }
      | 'class' 'identificador' '{' '}'                     { $$ = { 'nombreClase': $2, 'contenidoClase': [] }; }
      | 'class' error '{' BODYCLASS '}'                     { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
      | 'class' error '{' '}'                               { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
      | error ERROR                                         { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
      ;

CUERPOCLASE : CUERPOCLASE METODO            { $1.push($2); $$ = $1; }
            | CUERPOCLASE DECLARACION       { $1.push($2); $$ = $1; }
            | METODO                        { $$ = [$1]; }
            | DECLARACION                   { $$ = [$1]; }
            | error ERROR                   { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
            ;

METODO : 'void' 'identificador' '(' ')' CUERPO                { $$ = {'nombreMetodo': $2, 'tipo': $1, 'parametrosMetodo': [], 'contenidoMetodo': $5 }; if(returnSetencia && returnExpresion) { listaErrores.push(new Error(idError, 'Error Sintactico', lineaError, columnaError, 'Valor de retorno inesperado')); console.error('Error Sintactico: Valor de retorno inesperado en la linea ' + lineaError + ' y columna ' + columnaError); idError++; } returnSetencia = false; if(contadorBreak>0 || contadorContinue>0) { listaErrores.push(new Error(idError, 'Error Sintactico', lineaError, columnaError, 'break o continue fuera de ciclo')); console.error('Error Sintactico: break o continue fuera de ciclo en la linea ' + lineaError + ' y columna ' + columnaError); idError++; } contadorBreak = 0; contadorContinue = 0; }
       | TIPO 'identificador' '(' ')' CUERPO                  { $$ = {'nombreMetodo': $2, 'tipo': $1, 'parametrosMetodo': [], 'contenidoMetodo': $5 }; if(returnSetencia && !returnExpresion) { listaErrores.push(new Error(idError, 'Error Sintactico', lineaError, columnaError, 'Falta valor de retorno')); console.error('Error Sintactico: Falta valor de retorno en la linea ' + lineaError + ' y columna ' + columnaError); idError++; } returnSetencia = false; if(contadorBreak>0 || contadorContinue>0) { listaErrores.push(new Error(idError, 'Error Sintactico', lineaError, columnaError, 'break o continue fuera de ciclo')); console.error('Error Sintactico: break o continue fuera de ciclo en la linea ' + lineaError + ' y columna ' + columnaError); idError++; } contadorBreak = 0; contadorContinue = 0; }
       | 'void' 'identificador' '(' PARAMETROS ')' CUERPO     { $$ = {'nombreMetodo': $2, 'tipo': $1, 'parametrosMetodo': $4, 'contenidoMetodo': $6 }; if(returnSetencia && returnExpresion) { listaErrores.push(new Error(idError, 'Error Sintactico', lineaError, columnaError, 'Valor de retorno inesperado')); console.error('Error Sintactico: Valor de retorno inesperado en la linea ' + lineaError + ' y columna ' + columnaError); idError++; } returnSetencia = false; if(contadorBreak>0 || contadorContinue>0) { listaErrores.push(new Error(idError, 'Error Sintactico', lineaError, columnaError, 'break o continue fuera de ciclo')); console.error('Error Sintactico: break o continue fuera de ciclo en la linea ' + lineaError + ' y columna ' + columnaError); idError++; } contadorBreak = 0; contadorContinue = 0; }
       | TIPO 'identificador' '(' PARAMETROS ')' CUERPO       { $$ = {'nombreMetodo': $2, 'tipo': $1, 'parametrosMetodo': $4, 'contenidoMetodo': $6 }; if(returnSetencia && !returnExpresion) { listaErrores.push(new Error(idError, 'Error Sintactico', lineaError, columnaError, 'Falta valor de retorno')); console.error('Error Sintactico: Falta valor de retorno en la linea ' + lineaError + ' y columna ' + columnaError); idError++; } returnSetencia = false; if(contadorBreak>0 || contadorContinue>0) { listaErrores.push(new Error(idError, 'Error Sintactico', lineaError, columnaError, 'break o continue fuera de ciclo')); console.error('Error Sintactico: break o continue fuera de ciclo en la linea ' + lineaError + ' y columna ' + columnaError); idError++; } contadorBreak = 0; contadorContinue = 0; }
       | 'void' error                                         { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
       ;

TIPO : 'int'        { $$ = 'int'; }
     | 'double'     { $$ = 'double'; }
     | 'boolean'    { $$ = 'boolean'; }
     | 'char'       { $$ = 'char'; }
     | 'String'     { $$ = 'String'; }
     ;

PARAMETROS : PARAMETROS ',' PARAMETRO     { $1.push($3); $$ = $1; }
           | PARAMETRO                    { $$ = [$1]; }
           ;

PARAMETRO : TIPO 'identificador'   { $$ = { 'tipo': $1, 'identificador' : $2 }; }
          | error                  { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
          ;

CUERPO : '{' '}'              { $$ = []; }
       | '{' SENTENCIAS '}'     { $$ = $2; }
       | error                  { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
       ;

SENTENCIAS : SENTENCIAS SENTENCIA  { $1.push($2); $$ = $1; }
           | SENTENCIA            { $$ = [$1]; }
           ;

SENTENCIA : DECLARACION          { $$ = { 'declaracion' : $1 }; }
          | ASIGNACION           { $$ = { 'asignacion' : $1 }; }
          | LLAMADAMETODO ';'    { $$ = { 'llamadaMetodo' : $1 }; }
          | SOUT                 { $$ = $1; }
          | IF                   { $$ = $1; }
          | SWITCH               { $$ = { 'switch' : $1 }; contadorBreak--; contadorContinue--; }
          | FOR                  { $$ = { 'for' : $1 }; contadorBreak--; contadorContinue--; }
          | WHILE                { $$ = { 'while' : $1 }; contadorBreak--; contadorContinue--; }
          | DOWHILE              { $$ = { 'do' : $1 }; contadorBreak--; contadorContinue--; }
          | RETURN               { $$ = { 'return' : $1 }; }
          | BREAK                { $$ = 'break'; }
          | CONTINUE             { $$ = 'continue'; }
          | error                { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
          ;

DECLARACION : TIPO IDLIST ';'     { $$ = { 'tipo' : $1, identificadores: $2 }; }
            ;

IDLIST : IDLIST ',' ID      { $1.push($3); $$ = $1; }
       | ID                 { $$ = [$1]; }
       ;

ID : 'identificador'                      { $$ = {'identificador': $1 }; }
   | 'identificador' ASIGNAREXPRESION     { $$ = {'identificador': $1, 'valor' : $2 }; }
   ;

ASIGNACION : 'identificador' ASIGNAREXPRESION ';'     { $$ = {'identificador': $1, 'valor' : $2 }; }
           | 'identificador' '++' ';'                 { $$ = {'identificador': $1, 'valor' : $1 + ' + 1' }; }
           | 'identificador' '--' ';'                 { $$ = {'identificador': $1, 'valor' : $1 + ' - 1' }; }
           ;

ASIGNAREXPRESION : '=' EXPRESION      { $$ = $2; }
                 ;
 
EXPRESION : EXPRESION '+' EXPRESION        { $$ = $1 + $2 + $3; }
           | EXPRESION '-' EXPRESION       { $$ = $1 + $2 + $3; }
           | EXPRESION '*' EXPRESION       { $$ = $1 + $2 + $3; }
           | EXPRESION '/' EXPRESION       { $$ = $1 + $2 + $3; }
           | EXPRESION '^' EXPRESION       { $$ = $1 + $2 + $3; }
           | EXPRESION '%' EXPRESION       { $$ = $1 + $2 + $3; }
           | EXPRESION '<' EXPRESION       { $$ = $1 + $2 + $3; }
           | EXPRESION '>' EXPRESION       { $$ = $1 + $2 + $3; }
           | EXPRESION '<=' EXPRESION      { $$ = $1 + $2 + $3; }
           | EXPRESION '>=' EXPRESION      { $$ = $1 + $2 + $3; }
           | EXPRESION '==' EXPRESION      { $$ = $1 + $2 + $3; }
           | EXPRESION '!=' EXPRESION      { $$ = $1 + $2 + $3; }
           | EXPRESION '||' EXPRESION      { $$ = $1 + $2 + $3; }
           | EXPRESION '&&' EXPRESION      { $$ = $1 + $2 + $3; }
           | '(' EXPRESION ')'             { $$ = $1 + $2 + $3; }
           | '-' EXPRESION %prec UMINUS    { $$ = $1 + $2; }
           | '!' EXPRESION                 { $$ = $1 + $2; }
           | 'identificador'               { $$ = $1; }
           | 'cadena'                      { $$ = $1; }
           | 'caracter'                    { $$ = $1; }
           | 'decimal'                     { $$ = $1; }
           | 'true'                        { $$ = $1; }
           | 'false'                       { $$ = $1; }
           | LLAMADAMETODO                 { $$ = $1; }
           ;

LLAMADAMETODO : 'identificador' '(' ')'                       { $$ = { 'identificadorMetodo' : $1, 'parametros' : [] }; }
             | 'identificador' '(' PARAMETROSLLAMADA ')'      { $$ = { 'identificadorMetodo' : $1, 'parametros' : $3 }; }
             ;

PARAMETROSLLAMADA : PARAMETROSLLAMADA ',' EXPRESION       { $1.push($3); $$ = $1; }
                  | EXPRESION                             { $$ = [$1]; }
                  ;

SOUT : 'print' '(' ')' ';'          { $$ = { 'print' : [] }; }
     | 'println' '(' ')' ';'        { $$ = { 'println' : [] }; }
     | 'print' CONDICION ';'        { $$ = { 'print' : $2 }; }
     | 'println' CONDICION ';'      { $$ = { 'println' : $2 }; }
     ;
     
CONDICION : '(' EXPRESION ')'      { $$ = $2; } 
          | error                  { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
          ;

IF : 'if' CONDICION CUERPO                    { $$ = { 'if' : { 'condicion' : $2, 'sentencias' : $3 } }; }
   | 'if' CONDICION CUERPO 'else' IF          { $$ = { 'if' : { 'condicion' : $2, 'sentencias' : $3 }, 'else': $5 }; }
   | 'if' CONDICION CUERPO 'else' CUERPO      { $$ = { 'if' : { 'condicion' : $2, 'sentencias' : $3 }, 'else': $5 }; }
   ;

SWITCH : 'switch' CONDICION '{' CASES DEFAULT '}'       { $$ = { 'condicion' : $2, 'sentenciasCase' : $4, 'default': $5 }; }
       | 'switch' CONDICION '{' CASES '}'               { $$ = { 'condicion' : $2, 'sentenciasCase' : $4 }; }
       | 'switch' CONDICION '{' DEFAULT '}'             { $$ = { 'condicion' : $2, 'default' : $4 }; }
       | 'switch' CONDICION '{' '}'                     { $$ = { 'condicion' : $2 }; }
       | 'switch' CONDICION '{' error ERROR '}'         { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
       ;

CASES : CASES CASE      { $1.push($2); $$ = $1; }
      | CASE            { $$ = [$1]; }
      ;

CASE : 'case' EXPRESION ':'                { $$ = { 'expresion' : $2, 'sentencias' : [] }; }
     | 'case' EXPRESION ':' SENTENCIAS     { $$ = { 'expresion' : $2, 'sentencias' : $4 }; }
     | 'case' error                        { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
     ;

DEFAULT : 'default' ':'                 { $$ = { 'sentencias' : [] }; }
        | 'default' ':' SENTENCIAS      { $$ = { 'sentencias' : $3 }; }
        | 'default' error               { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
        ;

FOR : 'for' '(' TIPO 'identificador' ASIGNAREXPRESION ';' EXPRESION ';' ITERATOR ')' CUERPO    { $$ = { 'initializer' : { 'tipo' : $3, identificador: $4, 'valor' : $5 }, 'condicion' : $7, 'iterator' : $9, 'sentencias' : $11 }; }
    | 'for' '(' 'identificador' ASIGNAREXPRESION ';' EXPRESION ';' ITERATOR ')' CUERPO         { $$ = { 'initializer' : { identificador: $3, 'valor' : $4 }, 'condicion' : $6, 'iterator' : $7, 'sentencias' : $10 }; }
    | 'for' error                                                                              { listaErrores.push(new Error(idError, 'Error Sintactico', this._$.first_line, this._$.first_column, yytext + ' se esperaba ' + yy.parser.hash.expected)); console.error('Error Sintactico: ' + yytext + ' se esperaba ' + yy.parser.hash.expected + ' en la linea ' + this._$.first_line + ' y columna ' + this._$.first_column); idError++; }
    ;

ITERATOR : 'identificador' '++'    { $$ = {'identificador': $1, 'valor' : $1 + ' + 1' }; }
         | 'identificador' '--'    { $$ = {'identificador': $1, 'valor' : $1 + ' - 1' }; }
         ;

WHILE : 'while' CONDICION CUERPO      { $$ = { 'condicion' : $2, 'sentencias' : $3 }; }
      ;

DOWHILE : 'do' CUERPO 'while' CONDICION ';'  { $$ = { 'sentencias' : $2, 'while' : $4 }; }
        ;

RETURN : 'return' ';'               { $$ = ''; returnExpresion = false; returnSetencia = true; lineaError = this._$.first_line; columnaError = this._$.first_column; }
	| 'return' EXPRESION ';'     { $$ = $2; returnExpresion = true; returnSetencia = true; lineaError = this._$.first_line; columnaError = this._$.first_column; }
	;

BREAK : 'break' ';' { contadorBreak++; lineaError = this._$.first_line; columnaError = this._$.first_column; }
      ;

CONTINUE : 'continue' ';' { contadorContinue++; lineaError = this._$.first_line; columnaError = this._$.first_column; }
	  ;

ERROR : '{'
      | '}'
      | '('
      | ')'
      | ':'
      ;