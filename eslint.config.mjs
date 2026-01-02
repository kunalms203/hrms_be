import js from "@eslint/js";
import tsParser from "@typescript-eslint/parser";
import tsPlugin from "@typescript-eslint/eslint-plugin";
import prettier from "eslint-config-prettier";

export default [
  // -----------------------
  // 1. IGNORE GENERATED FILES
  // -----------------------
  {
    ignores: [
      "node_modules/**",
      "dist/**",
      "build/**",
      "generated/**",
      "**/*.d.ts",
    ],
  },

  // -----------------------
  // 2. BASE JS RULES
  // -----------------------
  js.configs.recommended,

  // -----------------------
  // 3. TYPESCRIPT RULES
  // -----------------------
  {
    files: ["**/*.ts"],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: "latest",
        sourceType: "module",
      },
      globals: {
        // Node + Bun globals
        process: "readonly",
        console: "readonly",
        Buffer: "readonly",
        setTimeout: "readonly",
        clearTimeout: "readonly",
      },
    },
    plugins: {
      "@typescript-eslint": tsPlugin,
    },
    rules: {
      ...tsPlugin.configs.recommended.rules,

      // Practical production rules
      "@typescript-eslint/no-unused-vars": [
        "error",
        { argsIgnorePattern: "^_" },
      ],
      "@typescript-eslint/no-explicit-any": "warn",

      // Disable noisy rules for backend
      "@typescript-eslint/no-empty-object-type": "off",
      "@typescript-eslint/no-unsafe-function-type": "off",

      "no-console": "off", // backend logs are OK
      "eqeqeq": ["error", "always"],
    },
  },

  prettier,
];
