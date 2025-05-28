# ---- Build stage ----
FROM elixir:1.18-slim AS build

RUN apt-get update && apt-get install -y \
  git build-essential \
  && apt-get clean

WORKDIR /app

# If using MIX_ENV=prod, you need config/runtime.exs even if empty
COPY mix.exs mix.lock ./
COPY lib lib

RUN mix local.hex --force && mix local.rebar --force
ENV MIX_ENV=prod
RUN mix deps.get
RUN mix deps.compile
RUN mix release

# ---- Final image ----
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
  libstdc++6 \
  libssl3 \
  libncurses6 \
  && apt-get clean

RUN apt-get update && apt-get install -y \
  curl docker.io bash \
  && apt-get clean

WORKDIR /app
COPY --from=build /app/_build/prod/rel/scan_service ./

ENV HOME=/app
ENV MIX_ENV=prod
EXPOSE 4001

CMD ["bin/scan_service", "start"]
