import { Router } from "express";
import { listCatalog } from "../services/catalogService.js";

export const catalogRoutes = Router();

catalogRoutes.get("/skills", async (_req, res, next) => {
  try {
    res.json({ skills: await listCatalog() });
  } catch (error) {
    next(error);
  }
});
