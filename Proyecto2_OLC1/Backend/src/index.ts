import express, { Application } from 'express';
import morgan from 'morgan';
import cors from 'cors';

import indexRoutes from './routes/indexRoutes';

class Server {
    public app: Application;
    constructor() {
        this.app = express();
        this.config();
        this.routes();
    }

    config(): void {
        this.app.set('port', process.env.Port || 3000);
        this.app.use(morgan('dev'));
        this.app.use(cors({
            origin: '*'
        }));
        this.app.use(express.json());
        this.app.use(express.urlencoded({
            // application/x-www-form-urlencoded
            extended: true
        }));
    }

    routes(): void {
        this.app.use('/', indexRoutes);
        // this.app.use('/api/index', indexRoutes);
    }

    start(): void {
        this.app.listen(this.app.get('port'), () => {
            console.log('Listening on', this.app.get('port'));
        });
    }
};

const server = new Server();
server.start();