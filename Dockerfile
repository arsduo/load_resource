FROM elixir:1.4.4-slim

# Compile app
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# Install Elixir Deps
ADD mix.* ./
RUN mix local.hex --force \
  && mix local.rebar --force \
  && mix hex.info
RUN mix deps.get

# Install app
ADD . .

RUN mix compile
