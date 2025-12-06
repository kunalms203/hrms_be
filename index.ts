import express from "express"
import "dotenv/config";
import {prisma} from "./utils/db"
import { console } from "inspector";

const employee = await prisma.employees.create({
    data: {
      employee_code: "EMP001",
      first_name: "Kunal",
      last_name: "Shinde",
      email: "kunal@example.com",
      password_hash: "hashed_password_here"
    }
  });

const users = await prisma.employees.findMany();
console.log("all users",users);

const app = express();
const port = process.env.PORT;

app.listen(port,()=>{
    console.log(`App is listening on the http://localhost:${port}`);
})