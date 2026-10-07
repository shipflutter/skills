export class AppError extends Error {
  constructor(
    public status: number,
    public code: string,
    message: string
  ) {
    super(message);
  }
}

export function assertFound<T>(value: T | undefined | null, code: string, message: string): T {
  if (!value) throw new AppError(404, code, message);
  return value;
}
