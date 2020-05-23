import { Router } from 'express';
import { ReporteCopias } from '../controladores/ReporteCopias';
import { ReporteErrores } from '../controladores/ReporteErrores';

const parser = require('../gramatica/gramatica.js');

class IndexRoutes {
    public router: Router;

    constructor() {
        this.router = Router();
        this.config();
    }

    config(): void {
        this.router.get('/', (req, res) => {
            res.send('Prueba Ruta Funcionando');
        });

        this.router.post('/compare', (req, res) => {
            let data = req.body;
            console.log(data['Archivo1']);
            console.log(data['Archivo2']);
            try {
                const astArchivo1 = JSON.stringify(parser.parse(data['Archivo1']), null, 2);
                const astArchivo2 = JSON.stringify(parser.parse(data['Archivo2']), null, 2);
                const archivo1JSON = JSON.parse(astArchivo1);
                const archivo2JSON = JSON.parse(astArchivo2);

                let reporteErrores
                let erroresArchivo1;
                let erroresArchivo2;

                let reporteAST;
                let reporteClasesCopia;
                let reporteFuncionesCopia;
                let reporteVariablesCopia;

                if (archivo1JSON.hasOwnProperty('error')
                    || archivo2JSON.hasOwnProperty('error')) {
                    if (archivo1JSON.hasOwnProperty('error')) {
                        console.log('errores del archivo principal');
                        reporteErrores = new ReporteErrores(archivo1JSON);
                        erroresArchivo1 = reporteErrores.getErrorList();
                    }

                    if (archivo2JSON.hasOwnProperty('error')) {
                        console.log('errores de archivo secundario');
                        reporteErrores = new ReporteErrores(archivo2JSON);
                        erroresArchivo2 = reporteErrores.getErrorList();
                    }

                    let results = {
                        'erroresArchivo1': erroresArchivo1,
                        'erroresArchivo2': erroresArchivo2
                    }
                    res.status(200).send({
                        code: '200',
                        errors: results
                    });
                } else if (archivo1JSON.hasOwnProperty('class')
                    && archivo2JSON.hasOwnProperty('class')) {
                    let reporteCopias = new ReporteCopias(astArchivo1, astArchivo2);

                    reporteAST = reporteCopias.getDatosAST();
                    reporteClasesCopia = reporteCopias.getReporteClaseCopia();
                    reporteFuncionesCopia = reporteCopias.getReporteMetodosCopia();
                    reporteVariablesCopia = reporteCopias.getReporteVariablesCopia();

                    let results = {
                        'reporteAST': reporteAST,
                        'reporteClasesCopia': reporteClasesCopia,
                        'reporteFuncionesCopia': reporteFuncionesCopia,
                        'reporteVariablesCopia': reporteVariablesCopia
                    }
                    res.status(200).send({
                        code: '200',
                        data: results
                    });
                } else {
                    res.status(500).send('error en el análisis');
                    console.log('error en el análisis');
                }
            } catch (e) {
                res.status(400).json({result:"Error en Analisis"});
                console.error(e);
                return;
            }
        });
    }
}

const indexRoutes = new IndexRoutes();
export default indexRoutes.router;