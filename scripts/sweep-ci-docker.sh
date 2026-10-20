#!/bin/bash
set -euo pipefail

# Backstop for SQL test containers left behind when a pipeline job dies before its cleanup step.
# Pipeline jobs time out after 60 minutes, so anything older than this is no longer in use.
MAX_AGE_SECONDS=$((3 * 60 * 60))
now=$(date +%s)

for id in $(docker ps -aq --filter name=apport-sql-); do
  created=$(date -d "$(docker inspect --format '{{.Created}}' "$id")" +%s)
  if [ $((now - created)) -gt "$MAX_AGE_SECONDS" ]; then
    docker rm -f "$id"
  fi
done

docker builder prune --force --filter until=168h
docker image prune --force --filter until=168h
