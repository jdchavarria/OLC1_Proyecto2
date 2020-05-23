export class Error {
    private idError: number;
    private tipo: string;
    private linea: number;
    private columna: number;
    private descripcion: string;

    constructor(idError: number, tipo: string, linea: number, columna: number, descripcion: string) {
        this.idError = idError;
        this.tipo = tipo;
        this.linea = linea;
        this.columna = columna;
        this.descripcion = descripcion;
    }

    public getIdError(): number {
        return this.idError;
    }

    public setIdError(idError: number): void {
        this.idError = idError;
    }

    public getTipo(): string {
        return this.tipo;
    }

    public setTipo(tipo: string): void {
        this.tipo = tipo;
    }

    public getLinea(): number {
        return this.linea;
    }

    public setLinea(linea: number): void {
        this.linea = linea;
    }

    public getColumna(): number {
        return this.columna;
    }

    public setColumna(columna: number): void {
        this.columna = columna;
    }

    public getDescripcion(): string {
        return this.descripcion;
    }

    public setDescripcion(descripcion: string): void {
        this.descripcion = descripcion;
    }
};