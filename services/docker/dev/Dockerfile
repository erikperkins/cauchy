FROM elixir:1.14.3-slim
RUN apt-get update && apt-get install -y inotify-tools

WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
ENV MIX_ENV="prod"
COPY mix.exs mix.exs
RUN mix deps.get --only $MIX_ENV
RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY assets assets
RUN mix assets.deploy

COPY lib lib
RUN mix compile

COPY config/runtime.exs config/
# ARG PHOENIX_VERSION=1.7.0
# RUN mix archive.install hex phx_new #{PHOENIX_VERSION}

RUN mix release

CMD ["sh", "-c", "SECRET_KEY_BASE=`mix phx.gen.secret` mix phx.server"]
