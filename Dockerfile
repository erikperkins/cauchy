FROM elixir:1.14.3-slim
RUN apt-get update && apt-get install -y inotify-tools

ARG PHOENIX_VERSION=1.7.0
ENV MIX_ENV prod

RUN mix local.hex --force && mix local.rebar --force
RUN mix archive.install hex phx_new #{PHOENIX_VERSION}

RUN mkdir -p /app
COPY mix.exs mix.exs
COPY config/config.exs config/config.exs
COPY config/prod.exs config/prod.exs
COPY config/runtime.exs config/runtime.exs

RUN mix deps.get --only prod && mix deps.compile
COPY assets assets
COPY priv priv
RUN mix assets.deploy
COPY lib lib
RUN mix compile

CMD ["sh", "-c", "SECRET_KEY_BASE=`mix phx.gen.secret` mix phx.server"]
