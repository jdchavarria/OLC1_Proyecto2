import { Clase } from "../modelos/Clase";
import { Metodo } from "../modelos/Metodo";
import { Parametro } from "../modelos/Parametro";
import { Variable } from "../modelos/Variable";

export class ClaseEstructura {
    public clase: Clase;
    public entradaJSON: any;
    public declaraciones: any;
    public identificadores: any;

    constructor(entrada: string) {
        this.clase = new Clase();
        this.entradaJSON = JSON.parse(entrada);
        this.declaraciones = [];
        this.identificadores = [];

        this.estructurarClase();
    }

    public getDatos(): Clase {
        return this.clase;
    }

    public estructurarClase(): void {
        this.clase.setNombre(this.entradaJSON['class']['nombreClase']);

        let contenidoClase = this.entradaJSON['class']['contenidoClase'];
        this.estructurarMetodos(contenidoClase);
    }

    public estructurarMetodos(contenidoClase: any): void {
        for (let i = 0; i < Object.keys(contenidoClase).length; i++) {
            if (this.getLlave('nombreMetodo', contenidoClase[i]) != false) {
                let metodo: Metodo = new Metodo();
                metodo.setNombre(this.getLlave('nombreMetodo', contenidoClase[i]));
                metodo.setTipo(this.getLlave('tipo', contenidoClase[i]));

                // Se obtienen los parametros del metodo
                metodo.setParametros(this.estructurarParametros(this.getLlave('parametrosMetodo', contenidoClase[i])));

                // Se obtienen las variables declaradas en el metodo
                metodo.setVariabes(this.buildVariables(this.getLlave('contenidoMetodo', contenidoClase[i])));

                this.clase.getMetodos().push(metodo);
            }
        }
    }

    public estructurarParametros(parametro: any): Parametro[] {
        let listaParametros: Parametro[] = [];

        // Se recorre todo el listado de parametros en el JSON y se separan para retornarlos en una lista
        for (let i = 0; i < Object.keys(parametro).length; i++) {
            let parametroS: Parametro = new Parametro();
            parametroS.setTipo(this.getLlave('tipo', parametro[i]));
            parametroS.setIdentificador(this.getLlave('identificador', parametro[i]));

            listaParametros.push(parametroS);
        }
        return listaParametros;
    }

    public buildVariables(contenidoMetodo: any): Variable[] {
        let listaVariables: Variable[] = [];

        // Se recorren todas las setencias del metodo y se buscan las declaraciones para retornarlas en un listado
        this.declaraciones = [];
        this.getDeclaraciones(contenidoMetodo);

        // Del listado de declaraciones se obtienen los identificadores de cada lista de IDs
        this.identificadores = [];
        this.getIdentificadores(this.declaraciones);

        // Se crea la estructura de cada variable agregandole su tipo e identificador
        for (let i = 0; i < this.declaraciones.length; i++) {
            this.identificadores[i].forEach((elemento: any) => {
                listaVariables.push(new Variable(this.declaraciones[i].tipo, elemento.identificador))
            });
        }
        return listaVariables;
    }

    public getDeclaraciones(contenidoMetodo: any): void {
        Object.keys(contenidoMetodo).forEach(key => {
            var valor = contenidoMetodo[key];
            if (Array.isArray(valor) || typeof valor === 'object') {
                if (key == 'declaracion') {
                    this.declaraciones.push(valor);
                }
                this.getDeclaraciones(valor);
            }
        });
    }

    public getIdentificadores(identificador: any): void {
        Object.keys(identificador).forEach(key => {
            var valor = identificador[key];
            if (Array.isArray(valor) || typeof valor === 'object') {
                if (key == 'identificadores') {
                    this.identificadores = this.identificadores.concat([valor]);
                }
                this.getIdentificadores(valor);
            }
        });
    }

    public getLlave(matchString: string, jsonObject: any): any {
        let expression: RegExp = new RegExp(matchString);

        for (var key in jsonObject) {
            if (jsonObject.hasOwnProperty(key)) {
                if (expression.test(key)) {
                    return jsonObject[key];
                }
            }
        }
        return false;
    }
};
