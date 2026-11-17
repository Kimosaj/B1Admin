# ==========================================
# Build Stage
# ==========================================
FROM node:22-slim AS build

WORKDIR /app

RUN corepack enable

# Dependency manifests
COPY package.json yarn.lock .yarnrc.yml ./

# Required Yarn patches
COPY .yarn/patches/ .yarn/patches/

# Install dependencies
RUN yarn install --immutable && yarn postinstall

# Application source
COPY . .

# Self-host configuration
ENV REACT_APP_STAGE=selfhost
ENV VITE_BASE_PATH=/admin/

# Build application
RUN yarn build


# ==========================================
# Production Stage
# ==========================================
FROM node:22-slim

# Install static web server
RUN npm install -g serve@14.2.6

WORKDIR /app

# Copy compiled application from build stage
COPY --from=build /app/dist ./dist

EXPOSE 3101

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=6 CMD node -e "fetch('http://127.0.0.1:3101/').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

# Start web server
CMD ["serve", "-s", "dist", "-l", "3101"]