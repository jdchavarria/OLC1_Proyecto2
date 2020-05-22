//TIPO DE DATOS PARA VARIABLES
const Tipo_Dato ={
    Tipo_Int: 'Val_entero',
    Tipo_String: 'Val_String',
    Tipo_Char: 'Val_Char',
    Tipo_Boolean: 'Val_Boolean', 
    Tipo_Double: 'Val_Double',
}

//constantes para las operaciones
const Tipo_Operacion={
    SUMA: 'OP_SUMA',
    RESTA: 'OP_RESTA',
    MULTIPLICACION: 'OP_MULTIPLICACION',
    DIVISION: 'OP_DIVISION',
    NEGATIVO: 'OP_NEGATIVO',
    MAYOR_QUE: 'OP_MAYOR_QUE',
    MENOR_QUE: 'OP_MENOR_QUE',
    MAYOR_IGUAL: 'OP_MAYOR_IGUAL',
    MENOR_IGUAL: 'OP_MENOR_IGUAL',
    DOBLE_IGUAL: 'OP_DOBLE_IGUAL',
    NO_IGUAL: 'OP_NO_IGUAL',
    AND: 'OP_AND',
    OR: 'OP:OR',
    NOT: 'OP_NOT',
    CONCATENACION:  'OP_CONCATENACION'
};

//TIPO DE INSTRUCCIONES

const Tipo_Instruccion={
    IMPRIMIR: 'INSTR_IMPRI',
    WHILE: 'INSTR_WHILE',
    DECLARACION: 'INSTR_DECLA',
    ASIGNACION: 'INSTR_ASIGNACION',
    IF: 'INSTRU_IF',
    IF_ELSE: 'INSTR_ELSE',
    FOR: 'INSTR_FOR' ,
    IMPORT: 'INSTR_IMPORT',
    MAIN: 'INSTR_MAIN',
    SWITCH: 'INSTR_SWITCH',
    SWITCH_OP: 'INSTR_SWITCH_OP',
    CLASE: 'INSTR_CLASE'
}

const TIPO_OPCION_SWITCH={
    CASO:'CASO',
    DEFECTO: 'DEFECTO'
}
    // OPEACION PARA CONCATENAR LAS OPERACIONES
function nuevaOperacion(opera_iz,opera_der,tipo){
    return {
        opera_iz:opera_iz,
        opera_der:opera_der,
        tipo:tipo
    }
}
// ESTO CONTIENE TODAS LAS INSTRUCCIONES QUE RETORNAN DATOS PARA CREAR EL AST
const instruccionesAPI={
    nuevoOperacionBinaria: function(operandoIzq, operandoDer, tipo) {
		return nuevaOperacion(operandoIzq, operandoDer, tipo);
	},

    nuevoOperacionUnaria: function(operando, tipo) {
		return nuevaOperacion(operando, undefined, tipo);
    },
    
    nuevoValor: function(valor, tipo) {
		return {
			tipo: tipo,
			valor: valor
		}
    },

    nuevoImprimir:function(expresion){
        return{
            tipo: Tipo_Instruccion.IMPRIMIR,
            expresionCadena:expresion
        };
    },

    nuevoMientras:function(expresion_logica,instrucciones){
        return{
            tipo: Tipo_Instruccion.WHILE,
            expresion_logica: expresion_logica,
            instrucciones: instrucciones
        };
    },

    nuevoPara:function(variable,valorVariable,expresionLogica,aumento,instrucciones){
        return{
            tipo: Tipo_Instruccion.FOR,
            expresionLogica: expresionLogica,
            instrucciones: instrucciones,
            aumento: aumento,
            variable:variable,
            valorVariable: valorVariable
        }
    },

    //CREA OBJETO DECLARACION
    
    nuevoDeclaracion: function(identificador, tipo) {
        console.log(identificador);
		return {
			tipo: Tipo_Instruccion.DECLARACION,
			identificador: identificador,
            tipo_dato: tipo
        };
        console.log(tipo);
	},


	/**
	 * Crea un objeto tipo Instrucción para la sentencia Asignación.
	 * @param {*} identificador 
	 * @param {*} expresionNumerica 
	 */
	nuevoAsignacion: function(identificador, expresionNumerica) {
		return {
			tipo: Tipo_Instruccion.ASIGNACION,
			identificador: identificador,
			expresionNumerica: expresionNumerica
		}
    },

    //CREA OBJETOS IF
    nuevoIf:function(expresionLogica,instrucciones){
        console.log(expresionLogica);
        console.log(instrucciones);
        return{
            tipo: Tipo_Instruccion.IF,
            expresionLogica: expresionLogica,
            instrucciones:instrucciones
        };
    },
    //CREA OBJETOS IF ANIDADO
    nuevoIfElse:function(expresionLogica,instruccionesIfVerdadero,instruccionesIfFalso){
        return{
            tipo: Tipo_Instruccion.IF_ELSE,
            expresionLogica: expresionLogica,
            instruccionesIfVerdadero: instruccionesIfVerdadero,
            instruccionesIfFalso: instruccionesIfFalso
        }
    },

    nuevoSwitch: function(expresionNumerica, casos) {
		return {
			tipo: Tipo_Instruccion.SWITCH,
			expresionNumerica: expresionNumerica,
			casos: casos
		}
    },
    
    nuevoListaCasos: function (caso) {
		var casos = []; 
		casos.push(caso);
		return casos;
    },

    nuevoCaso: function(expresionNumerica, instrucciones) {
		return {
			tipo: TIPO_OPCION_SWITCH.CASO,
			expresionNumerica: expresionNumerica,
			instrucciones: instrucciones
		}
	},
    
    nuevoCasoDef: function(instrucciones) {
		return {
			tipo: TIPO_OPCION_SWITCH.DEFECTO,
			instrucciones: instrucciones
		}
    },
    
    nuevoOperador: function(operador){
		return operador 
	},

    //RETORNA OBJETO MAIN
    nuevoMain:function(instrucciones){
        return{
            tipo: Tipo_Instruccion.MAIN,
            instrucciones: instrucciones
        }
    },
    //RETORNA OBJETO CLASE
    nuevoClass:function(name,instrucciones){
        return{
            tipo: Tipo_Instruccion.CLASE,
            nombre: name,
            instrucciones: instrucciones
        }
    },

    nuevoImport:function(name){
        return{
            tipo: Tipo_Instruccion.IMPORT,
            nombre: name
        }
    }
    

}
    //MODULOS DE EXPORTACION
module.exports.Tipo_Operacion=Tipo_Operacion;
module.exports.Tipo_Instruccion = Tipo_Instruccion;
module.exports.instruccionesAPI = instruccionesAPI;
module.exports.Tipo_Dato = Tipo_Dato;