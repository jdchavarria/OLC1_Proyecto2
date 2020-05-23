export class Variable {
    private tipo: string;
    private nombre: string;

    constructor(tipo: string, nombre: string, ) {
        this.tipo = tipo;
        this.nombre = nombre;
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
};
