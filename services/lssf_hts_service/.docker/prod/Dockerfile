# Stage 1: Build the Phoenix release
FROM hexpm/elixir:1.16.2-erlang-26.2.3-alpine-3.19 AS build

RUN apk add --no-cache build-base git npm nodejs python3 postgresql-client

ENV MIX_ENV=prod
WORKDIR /app

# Cache dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy and build assets
COPY assets assets
RUN npm --prefix ./assets install
RUN npm --prefix ./assets run deploy

# Copy rest of the app
COPY lib lib
COPY priv priv
RUN mix compile
RUN mix release

# Stage 2: Minimal runtime image
FROM alpine:3.19 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs

ENV MIX_ENV=prod
WORKDIR /app

COPY --from=build /app/_build/prod/rel/my_app ./

EXPOSE 4000
CMD ["bin/my_app", "start"]
