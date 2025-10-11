import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";

// Chart.js setup for global usage in screens
import Chart from "chart.js/auto";

// Make Chart.js available globally for screens that use window.Chart
// (This is a workaround for direct chart instantiation in screen components)
if (typeof window !== "undefined") {
  // @ts-ignore
  window.Chart = Chart;
}

const root = createRoot(document.getElementById("root")!);
root.render(<App />);
