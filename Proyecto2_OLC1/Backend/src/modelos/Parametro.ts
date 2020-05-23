export class Parametro {
    private tipo: string;
    private identificador: string;

    constructor() {
        this.tipo = '';
        this.identificador = '';
    }

    public getTipo(): string {
        return this.tipo;
    }

    public setTipo(tipo: string) {
        this.tipo = tipo;
    }

    public getIdentificador(): string {
        return this.identificador
    }

    public setIdentificador(name: string) {
        this.identificador = name;
    }
};
