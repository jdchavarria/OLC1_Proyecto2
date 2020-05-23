import { Metodo } from "./Metodo";

export class Clase {
    private nombre: string;
    private metodos: Metodo[];

    constructor() {
        this.nombre = '';
        this.metodos = [];
    }

    public getNombre(): string {
        return this.nombre;
    }

    public setNombre(nombre: string) {
        this.nombre = nombre;
    }

    public getMetodos(): Metodo[] {
        return this.metodos;
    }

    public setMetodos(metodos: Metodo[]) {
        this.metodos = metodos;
    }
};
