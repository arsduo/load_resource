FROM elixir:1.4.4-slim

# Compile app
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# As a plug package it doesn't make much sense to run the plug in any other environment
ENV MIX_ENV test
# In order to have subsequent shells run in test mode
RUN echo "export MIX_ENV=test" >> /root/.bashrc

# Install Elixir Deps
ADD mix.* ./
RUN mix local.hex --force \
  && mix local.rebar --force \
  && mix hex.info
RUN mix deps.get

# Install app
ADD . .

RUN mix compile
