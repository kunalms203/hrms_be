import express from "express"
import "dotenv/config";
import {prisma} from "./utils/db"

const users = await prisma.employees.findMany();
console.log("all users",users);

const app = express();
const port = process.env.PORT;

app.listen(port,()=>{
    console.log(`App is listening on the http://localhost:${port}`);
})