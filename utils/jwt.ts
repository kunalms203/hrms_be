import type { JWTPayload } from '../types/auth';

export function isJWTPayload(payload: any): payload is JWTPayload {
  return (
    typeof payload === 'object' &&
    payload !== null &&
    typeof payload.id === 'number' &&
    typeof payload.name === 'string'
  );
}
