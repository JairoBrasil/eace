/** @type {import('next').NextConfig} */
const nextConfig = {
  env: { NEXT_PUBLIC_APP_VERSION: process.env.NEXT_PUBLIC_APP_VERSION ?? "dev" },
};
export default nextConfig;
