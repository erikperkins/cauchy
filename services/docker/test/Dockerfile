FROM elixir:1.14.3-slim

WORKDIR /app
ENV MIX_ENV="test"
RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.exs
RUN mix deps.get --only $MIX_ENV
RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY lib lib
COPY test test
RUN mix compile
