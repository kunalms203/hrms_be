import express from "express";
import { registerUser, signIn } from "../controller/auth";

const router = express.Router();

router.post("/register", registerUser);

router.post("/login", signIn);

export default router;
