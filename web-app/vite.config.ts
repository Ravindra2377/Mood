// @ts-nocheck
// This file is a build-time config and relies on devDependencies that may
// not be installed in the current editor environment. Disable type checking
// here to avoid spurious Problems entries.
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: "../web-dist",
  },
  server: {
    proxy: {
      "/api": {
        target: "http://localhost:8000",
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
