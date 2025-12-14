import express from 'express';
import 'dotenv/config';
import mainRouter from './routes/index';

const app = express();
const port = process.env.PORT;

app.use(express.json());

app.use('/api/v1', mainRouter);

app.listen(port, () => {
  console.log(`App is listening on the http://localhost:${port}`);
});
