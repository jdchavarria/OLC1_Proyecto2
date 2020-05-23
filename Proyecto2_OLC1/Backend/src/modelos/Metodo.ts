import { Parametro } from './Parametro';
import { Variable } from "./Variable";

export class Metodo {
    private tipo: string;
    private nombre: string;
    private parametros: Parametro[];
    private variables: Variable[];

    constructor() {
        this.tipo = '';
        this.nombre = '';
        this.parametros = [];
        this.variables = [];
    }

    public getTipo(): string {
        return this.tipo;
    }

    public setTipo(tipo: string) {
        this.tipo = tipo;
    }

    public getNombre(): string {
        return this.nombre;
    }

    public setNombre(nombre: string) {
        this.nombre = nombre;
    }

    public getParametros(): Parametro[] {
        return this.parametros;
    }

    public setParametros(parametros: Parametro[]) {
        this.parametros = this.parametros.concat(parametros);
    }

    public getVariables(): Variable[] {
        return this.variables;
    }

    public setVariabes(variables: Variable[]) {
        this.variables = this.variables.concat(variables);
    }
};
