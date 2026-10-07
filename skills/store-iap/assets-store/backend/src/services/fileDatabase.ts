import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import type { DatabaseShape } from "../types/domain.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const dataDir = path.resolve(__dirname, "../../data");
const dbPath = path.join(dataDir, "db.json");

const emptyDb: DatabaseShape = {
  users: [],
  sessions: [],
  skills: [],
  skillPlans: [],
  orders: [],
  paymentInstructions: [],
  paymentTransactions: [],
  entitlements: []
};

export class FileDatabase {
  private writeQueue = Promise.resolve();

  async read(): Promise<DatabaseShape> {
    await mkdir(dataDir, { recursive: true });
    try {
      const raw = await readFile(dbPath, "utf8");
      return { ...emptyDb, ...JSON.parse(raw) };
    } catch (error: unknown) {
      if ((error as NodeJS.ErrnoException).code === "ENOENT") {
        await this.write(emptyDb);
        return structuredClone(emptyDb);
      }
      throw error;
    }
  }

  async write(db: DatabaseShape): Promise<void> {
    await mkdir(dataDir, { recursive: true });
    this.writeQueue = this.writeQueue.then(() => writeFile(dbPath, `${JSON.stringify(db, null, 2)}\n`, "utf8"));
    await this.writeQueue;
  }

  async update(mutator: (db: DatabaseShape) => void | Promise<void>): Promise<DatabaseShape> {
    const db = await this.read();
    await mutator(db);
    await this.write(db);
    return db;
  }
}

export const fileDatabase = new FileDatabase();
