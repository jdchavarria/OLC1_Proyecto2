import { Clase } from '../modelos/Clase';
import { Metodo } from '../modelos/Metodo';
import { ClaseEstructura } from './ClaseEstructura';

export class ReporteCopias {
    private archivo1: Clase;
    private archivo2: Clase;
    private datosAST: string;
    private datosClaseCopia: any;
    private datosMetodosCopia: any;
    private datosVariablesCopia: any;

    constructor(entrada1: string, entrada2: string) {
        this.archivo1 = new ClaseEstructura(entrada1).getDatos();
        this.archivo2 = new ClaseEstructura(entrada2).getDatos();
        this.datosAST = '';
        this.datosClaseCopia = {};
        this.datosMetodosCopia = {};
        this.datosVariablesCopia = {};

        this.reporteClaseCopia();
        this.reporteMetodosCopia();
        this.reporteVariablesCopia();
        this.reporteAST(JSON.parse(entrada1));
    }

    public getDatosAST(): string {
        return this.datosAST;
    }

    public getReporteClaseCopia(): any {
        return JSON.stringify(this.datosClaseCopia, null, 2);
    }

    public getReporteMetodosCopia(): any {
        return JSON.stringify(this.datosMetodosCopia, null, 2);
    }

    public getReporteVariablesCopia(): any {
        return JSON.stringify(this.datosVariablesCopia, null, 2);
    }

    private reporteClaseCopia(): void {
        let esCopia = false;

        // Se verifica que las clases tengan el mismo nombre y la misma cantidad de metodos
        if ((this.archivo1.getNombre() === this.archivo2.getNombre()) &&
            this.archivo1.getMetodos().length === this.archivo2.getMetodos().length) {
            this.archivo1.getMetodos().forEach(element => {
                // Se reccorren los metodos comparando nombres y tipos para verificar si es copia
                for (let i = 0; i < this.archivo2.getMetodos().length; i++) {
                    // Se agrega a un listado si es copia
                    if (element.getNombre() === this.archivo2.getMetodos()[i].getNombre() &&
                        element.getTipo() === this.archivo2.getMetodos()[i].getTipo()) {
                        esCopia = true;
                        break;
                    }

                    if (i === (this.archivo2.getMetodos().length - 1) &&
                        (element.getNombre() !== this.archivo2.getMetodos()[i].getNombre())) {
                        esCopia = false;
                    }
                }

                // Se rompe el ciclo si no es copia
                if (!esCopia) {
                    return;
                }
            });
        }

        if (esCopia) {
            // Se le da la estructura a los datos para el reporte
            let nombreMetodos: any = [];
            this.archivo1.getMetodos().forEach(element => {
                nombreMetodos.push({
                    'nombre del metodo': element.getNombre()
                });
            });
            this.datosClaseCopia = {
                'nombre de la clase': this.archivo1.getNombre(),
                'metodos': nombreMetodos,
                'numero de metodos': this.archivo1.getMetodos().length
            }
        }
    }

    private reporteMetodosCopia(): void {
        let metodos: Metodo[] = [];
        let esMetodoCopia = false;

        // Se verifica que las clases tengan el mismo nombre
        if (this.archivo1.getNombre() === this.archivo2.getNombre()) {
            this.archivo1.getMetodos().forEach(element => {
                // Se reccorren los metodos
                for (let i = 0; i < this.archivo2.getMetodos().length; i++) {
                    // Se verifica que los dos metodos a comparar contengan la misma cantidad de parametros
                    if (element.getParametros().length === this.archivo2.getMetodos()[i].getParametros().length) {
                        let cantidadParametros = element.getParametros().length;
                        // Se verifica si es un metodo sin parametros
                        if (cantidadParametros == 0) {
                            esMetodoCopia = true;
                        } else {
                            // Se recorren los parametros
                            for (let j = 0; j < cantidadParametros; j++) {
                                // Se verifica que el parametro cumpla con el mismo tipo en el mismo orden
                                if (element.getParametros()[j].getTipo() ===
                                    this.archivo2.getMetodos()[i].getParametros()[j].getTipo()) {
                                    esMetodoCopia = true;
                                } else {
                                    esMetodoCopia = false;
                                    break;
                                }
                            }
                        }
                    }

                    // Si cumple con los requisitos el metodo copia se agrega a un listado para el repore
                    if (esMetodoCopia && element.getTipo() == this.archivo2.getMetodos()[i].getTipo()) {
                        if (!metodos.includes(this.archivo2.getMetodos()[i])) {
                            metodos.push(this.archivo2.getMetodos()[i]);
                        }
                    }

                    esMetodoCopia = false;
                }
            });

            if (metodos.length > 0) {
                // Se le da la estructura a los datos para el reporte
                let datosMetodo: any = [];
                metodos.forEach(element => {
                    datosMetodo.push({
                        'tipo de metodo': element.getTipo(),
                        'nombre del metodo': element.getNombre(),
                        'parametros': element.getParametros()
                    });
                });
                this.datosMetodosCopia = {
                    'nombre de la clase': this.archivo2.getNombre(),
                    'metodos copia': datosMetodo
                }
            }
        }
    }

    private reporteVariablesCopia(): void {
        let metodos: Metodo[] = [];

        // Se verifica que las clases tengan el mismo nombre
        if (this.archivo1.getNombre() === this.archivo2.getNombre()) {
            // Se recorren los metodos
            this.archivo1.getMetodos().forEach(element => {
                // Se crea un metodo temporal para almacenar sus valores
                let metodo: Metodo = new Metodo();
                metodo.setNombre(element.getNombre());
                for (let i = 0; i < this.archivo2.getMetodos().length; i++) {
                    // Se verifica que el metodo tenga el mismo nombre y el mismo tipo
                    if (element.getTipo() === this.archivo2.getMetodos()[i].getTipo() &&
                        element.getNombre() === this.archivo2.getMetodos()[i].getNombre()) {
                        // Se recorren las varibables
                        element.getVariables().forEach(variable => {
                            for (let j = 0; j < this.archivo2.getMetodos()[i].getVariables().length; j++) {
                                // Se verifica que la variable tenga el mismo nombre y el mismo tipo
                                if (variable.getNombre() === this.archivo2.getMetodos()[i].getVariables()[j].getNombre() &&
                                    variable.getTipo() === this.archivo2.getMetodos()[i].getVariables()[j].getTipo()) {
                                    metodo.getVariables().push(variable);
                                }
                            }
                        });
                    }
                }

                // Se agrega el metodo a un listado temporal
                if (metodo.getVariables().length > 0) {
                    metodos.push(metodo);
                }
            });

            if (metodos.length > 0) {
                // Se le da la estructura a los datos para el reporte
                let datosMetodo: any = [];
                metodos.forEach(element => {
                    datosMetodo.push({
                        'nombre del metodo': element.getNombre(),
                        'variables': element.getVariables()
                    });
                });
                this.datosVariablesCopia = {
                    'nombre de la clase': this.archivo2.getNombre(),
                    'metodos': datosMetodo
                }
            }
        }
    }

    private reporteAST(jsonData: any): void {
        for (const i in jsonData) {
            if (Array.isArray(jsonData[i]) || typeof jsonData[i] === 'object') {
                this.datosAST += ('<ul><li class="jstree-open">' + i)
                this.reporteAST(jsonData[i]);
                this.datosAST += ('</li></ul>');
            } else {
                this.datosAST += ('<ul><li>' + i + ': ' + jsonData[i] + '</li></ul>');
            }
        }
    }
};