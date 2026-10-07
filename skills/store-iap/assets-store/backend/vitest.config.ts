import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    fileParallelism: false,
    include: ["src/**/*.test.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
      reportsDirectory: "coverage",
      include: ["src/services/**/*.ts", "src/utils/**/*.ts"],
      exclude: ["src/seed.ts", "src/server.ts"]
    }
  }
});
