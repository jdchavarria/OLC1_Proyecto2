import { Error } from '../modelos/Error';

export class ReporteErrores {
    private errores: any;
    private listaErrores: Array<Error>;

    constructor(errores: any) {
        this.errores = errores;
        this.listaErrores = [];

        this.updateList();
    }

    public updateList(): void {
        this.errores['error'].forEach((element: any) => {
            this.listaErrores.push(new Error(element['idError'], element['tipo'],
                element['linea'], element['columna'], element['descripcion']));
        });
    }

    public getErrorList(): string {
        let errorListData: string = '';

        this.listaErrores.forEach(element => {
            errorListData += '<tr>';
            errorListData += '<th>' + element.getIdError() + '</th>';
            errorListData += '<th>' + element.getTipo() + '</th>';
            errorListData += '<th>' + element.getDescripcion() + '</th>';
            errorListData += '<th>' + element.getLinea() + '</th>';
            errorListData += '<th>' + element.getColumna() + '</th>';
            errorListData += '</tr>';
        });
        return errorListData;
    }
};
