#!/bin/bash

set -euo pipefail

function inspect() {
  local image="$1"
  docker image inspect "$image"  | python3 -c "import sys, json; data=json.load(sys.stdin); print(f'{data[0][\"RepoTags\"][0]}\t{data[0][\"Size\"]}\t{len(data[0][\"RootFS\"][\"Layers\"])}')"
}

function run_until_healthy() {
  local image="$1"
  echo "Testing $1"

  # Run the container and capture the container ID
  local container_id
  container_id="$(docker run --rm --detach "$image")"

  # Wait for the container to become healthy
  until [ "$(docker inspect --format='{{json .State.Health.Status}}' "$container_id")" == "\"healthy\"" ]; do
    sleep 1;
  done

  # Stop the container
  docker stop "$container_id" > /dev/null
  echo "Success"
}


 docker build --target run-tests --progress plain .
 docker build -t go-test:scratch --target scratch .
 docker build -t go-test:distroless --target distroless .
 docker build -t go-test:debian-slim --target debian-slim .
 docker build -t go-test:alpine --target alpine .
 docker build -t go-test:ubuntu --target ubuntu .

inspect go-test:scratch
inspect go-test:distroless
inspect go-test:debian-slim
inspect go-test:alpine
inspect go-test:ubuntu

run_until_healthy go-test:scratch
run_until_healthy go-test:distroless
run_until_healthy go-test:debian-slim
run_until_healthy go-test:alpine
run_until_healthy go-test:ubuntu