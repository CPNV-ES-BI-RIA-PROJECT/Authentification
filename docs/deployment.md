# Deployment Guide

This document explains how to deploy the authentication component locally or on an integration pipeline by reusing the stack defined under `docs/example`.

## Overview

The `docs/example` folder contains a runnable Docker Compose configuration that stitches together:
- the `auth` service built from this repo, exposing its Sinatra API on port `4567`
- an `api-gateway` running NGINX, enforcing authentication with the `/check_auth` helper location
- an `api` mock backend (Mockoon) that consumes the authentication decisions and proves the routing behavior

Use this example when you want to replicate the integration environment or when validating your deployment changes.

## Prerequisites

1. Docker 28.1.1 or newer for composing the services.

## Preparing Image

The example Compose file expects the image to be built from the repository root. Build it once before starting the stack:

```bash
docker build -t auth-composant .
```

## Starting the Example Stack

From the repository root, launch the stack defined in `docs/example/compose.yml`:

```bash
cd docs/example
docker compose up --build
```

- `auth` mounts `./data/auth` (relative to `docs/example`) into `/app/storages` so you can inspect or seed persistence files next to the Docker Compose definition.
- `api-gateway` reads its NGINX configuration from `docs/example/config/nginx/default.conf` to proxy `/api/v1/*` to the `auth` service and forward `/users` requests to `api`.
- `api` loads the Mockoon collection stored in `docs/example/config/mockoon/data.json` to simulate downstream services.

## Verifying the Deployment

Once the stack is running:
1. `curl http://localhost/api/v1/sessions` should reach the auth component through NGINX.
2. `curl http://localhost/api/v1/users` triggers NGINX’s `auth_request` logic; without a valid session the gateway returns the custom 401 body defined in `default.conf`.
3. Inspect `docs/example/data` for storage artifacts written by the `auth` service.

## Customizing the Example for Your Environment

- Adjust environment variables by appending them to the `environment` section under `auth` in `docs/example/compose.yml` or by editing `.env` and passing `--env-file` when launching `docker compose`.
- Replace `Mockoon` data with your own fixtures in `docs/example/config/mockoon/data.json`.
- Update extra NGINX routing rules in `docs/example/config/nginx/default.conf` to expose new endpoints.
- Instead of building the image locally, you can use the public image `ghcr.io/cpnv-es-bi-ria-project/authentification:latest`

