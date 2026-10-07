import { Router } from "express";
import { createCheckoutSession, getOrder, receiveSepayWebhook } from "../services/checkoutService.js";
import { getSession } from "../services/authService.js";

export const checkoutRoutes = Router();

checkoutRoutes.post("/checkout/sessions", async (req, res, next) => {
  try {
    const token = req.header("authorization")?.replace(/^Bearer\s+/i, "");
    const session = await getSession(token);
    res.status(201).json(await createCheckoutSession(req.body, session?.user));
  } catch (error) {
    next(error);
  }
});

checkoutRoutes.get("/orders/:orderCode", async (req, res, next) => {
  try {
    const token = req.header("authorization")?.replace(/^Bearer\s+/i, "");
    const session = await getSession(token);
    res.json(await getOrder(req.params.orderCode, session?.user));
  } catch (error) {
    next(error);
  }
});

checkoutRoutes.post("/webhooks/sepay", async (req, res, next) => {
  try {
    res.json(await receiveSepayWebhook(req.body));
  } catch (error) {
    next(error);
  }
});
