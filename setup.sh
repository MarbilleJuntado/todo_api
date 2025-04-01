#!/bin/bash

# Create empty .env file
echo "" > .env
echo ".env file created."

# Run setup inside the web container
docker-compose build
docker-compose run web mix do deps.get, deps.compile, ecto.setup

# Generate Guardian secret and write to .env
SECRET=$(docker-compose run --rm --service-ports web mix phx.gen.secret)
echo "GUARDIAN_SECRET_KEY=$SECRET" >> .env
echo "GUARDIAN_SECRET_KEY added to .env"
