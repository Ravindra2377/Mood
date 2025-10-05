// Ambient declarations to quiet the editor when dev dependencies are not installed.
// These are minimal and intentionally permissive — they only exist to remove
// false-positive editor errors. Install the real types/devDependencies to
// replace these when you run `npm install` in the web-app folder.

declare module 'vite' {
  // Minimal stub of defineConfig — accepts anything and returns the same.
  export function defineConfig<T = any>(config: T): T;
  export type UserConfig = any;
}

declare module '@vitejs/plugin-react' {
  const plugin: any;
  export default plugin;
}

// Also guard against other common build plugins if the editor still complains.
declare module 'workbox-window' {
  export class Workbox {
    constructor(swUrl: string);
    register(): Promise<void>;
    addEventListener(name: string, cb: (...args: any[]) => void): void;
  }
}
