# syntax=docker/dockerfile:1
#
# Dev-server container for Locally Uncensored ("npm run dev" behind a browser).
#
# What this image is NOT: the desktop app. The browser build has fewer features
# than the installed Tauri app (no native window, no bundled engine); use the
# installer from Releases for real use — the setup scripts say the same thing.
#
# Also missing on purpose: no Ollama, no Python, no ComfyUI. The image only
# carries the Vite dev server and its Node dependencies, so `python3: not found`
# in the logs is expected here, and STT / ComfyUI stay off inside the container.
# Point COMFYUI_PATH at a Linux path only if you mount a ComfyUI plus a Python
# into it yourself; on a Windows host the native path is not visible in here.

FROM node:22-bookworm-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .

FROM node:22-bookworm-slim
WORKDIR /app
COPY --from=build /app /app

# Bind on all interfaces so the published port is reachable; the compose file
# maps it to 127.0.0.1 by default.
ENV HOST=0.0.0.0 \
    PORT=5273
EXPOSE 5273

# The same command as the compose service: Vite on the desktop app's devUrl
# port. `--host` also opens /shell-execute and /execute-code to the network the
# port is published into (the dev server warns about this at startup), which is
# why the compose file publishes on loopback only.
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5273"]
