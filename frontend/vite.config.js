import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    // During local development, forward API calls to the FastAPI server
    proxy: { "/api": "http://localhost:8000" },
  },
});
