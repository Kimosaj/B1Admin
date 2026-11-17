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

ENV REACT_APP_STAGE=selfhost
ENV VITE_BASE_PATH=/admin/

RUN yarn build