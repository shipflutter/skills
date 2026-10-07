import cors from "cors";
import express, { type ErrorRequestHandler } from "express";
import morgan from "morgan";
import { ZodError } from "zod";
import { authRoutes } from "./routes/authRoutes.js";
import { catalogRoutes } from "./routes/catalogRoutes.js";
import { checkoutRoutes } from "./routes/checkoutRoutes.js";
import { AppError } from "./utils/errors.js";

const app = express();
const port = Number(process.env.PORT ?? 5174);

app.use(cors({ origin: true }));
app.use(express.json({ limit: "1mb" }));
app.use(morgan("dev"));

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "skill-store-backend" });
});

app.use("/api/auth", authRoutes);
app.use("/api", catalogRoutes);
app.use("/api", checkoutRoutes);

const errorHandler: ErrorRequestHandler = (error, _req, res, _next) => {
  if (error instanceof ZodError) {
    res.status(400).json({ code: "validation_error", issues: error.issues });
    return;
  }

  if (error instanceof AppError) {
    res.status(error.status).json({ code: error.code, message: error.message });
    return;
  }

  console.error(error);
  res.status(500).json({ code: "internal_error", message: "Unexpected server error" });
};

app.use(errorHandler);

app.listen(port, () => {
  console.log(`Skill Store API listening on http://localhost:${port}`);
});
