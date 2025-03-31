FROM elixir:1.18

RUN mix local.hex --force \
    && mix archive.install --force hex phx_new \
    && mix local.rebar --force

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

COPY mix.exs .
COPY mix.lock .

CMD mix deps.get && mix phx.server
