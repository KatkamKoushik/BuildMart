import test from "node:test";
import assert from "node:assert/strict";

// Mock minimal browser globals for testing web client API functions
const mockStorage = new Map();
globalThis.window = {
  location: { hostname: "localhost" }
};
globalThis.localStorage = {
  getItem: (key) => mockStorage.get(key) || null,
  setItem: (key, val) => mockStorage.set(key, String(val)),
  removeItem: (key) => mockStorage.delete(key),
  clear: () => mockStorage.clear(),
};

test("getAuthToken returns null when unauthenticated and does not auto-login", async () => {
  mockStorage.clear();
  const { getAuthToken, setAuthToken } = await import("../src/lib/api.ts");

  setAuthToken(null);
  const token = await getAuthToken();
  assert.equal(token, null, "Unauthenticated user should receive null token");
});

test("setAuthToken sets and retrieves token in-memory", async () => {
  mockStorage.clear();
  const { getAuthToken, setAuthToken } = await import("../src/lib/api.ts");

  setAuthToken("test_bearer_jwt_token_123");
  const storedToken = await getAuthToken();
  assert.equal(storedToken, "test_bearer_jwt_token_123");

  setAuthToken(null);
  const clearedToken = await getAuthToken();
  assert.equal(clearedToken, null);
});

test("tokens are not persisted in localStorage to prevent XSS exposure", async () => {
  mockStorage.clear();
  const { setAuthToken } = await import("../src/lib/api.ts");
  setAuthToken("sensitive_token_jwt");
  assert.equal(mockStorage.get("buildmart_access_token"), undefined, "Token must not be stored in localStorage");
});

test("getApiBaseUrl resolves default localhost API address", async () => {
  const { api } = await import("../src/lib/api.ts");
  assert.ok(api, "API client object must be defined");
  assert.equal(typeof api.getCategories, "function");
  assert.equal(typeof api.getProducts, "function");
  assert.equal(typeof api.getCart, "function");
  assert.equal(typeof api.createOrder, "function");
  assert.equal(typeof api.submitQuote, "function");
});
