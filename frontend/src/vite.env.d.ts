// src/vite-env.d.ts 或 src/custom.d.ts
declare module "*.svg" {
    const content: string;
    export default content;
}
declare module "*.png" {
    const content: string;
    export default content;
}
