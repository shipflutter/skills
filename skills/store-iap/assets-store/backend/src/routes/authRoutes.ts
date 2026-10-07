import { Router } from "express";
import { getSession, signIn, signUp } from "../services/authService.js";

export const authRoutes = Router();

authRoutes.post("/sign-up", async (req, res, next) => {
  try {
    res.status(201).json(await signUp(req.body));
  } catch (error) {
    next(error);
  }
});

authRoutes.post("/sign-in", async (req, res, next) => {
  try {
    res.json(await signIn(req.body));
  } catch (error) {
    next(error);
  }
});

authRoutes.get("/me", async (req, res, next) => {
  try {
    const token = req.header("authorization")?.replace(/^Bearer\s+/i, "");
    const session = await getSession(token);
    res.json({ user: session?.user ?? null });
  } catch (error) {
    next(error);
  }
});
