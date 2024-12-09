#! /usr/bin/bash
# shellcheck shell=bash


POSTGRES_DIR="${1:?"Need path to postgres dir"}"
POSTGRES_DIR="$(readlink -m "$POSTGRES_DIR")"
POSTGRES_VERSION=$(ls /usr/lib/postgresql | tail -n 1)

# add postgres binaries to path
export PATH=$PATH:/usr/lib/postgresql/$POSTGRES_VERSION/bin/

# set postgres env variables
export PGHOST="${PGHOST:-localhost}"
export PGPORT="${PGPORT:-5433}"
export PGUSER="${PGUSER:-artur}"

# kill running postgres and clear its data
if [ "${2:-""}" = "-k" ]; then
  echo "Killing process listening on database port $PGPORT"
  listening_pid="$(lsof -i:"$PGPORT" -t || echo "")"
  if [ -n "$listening_pid" ]; then
    kill -9 "$listening_pid"
  fi
  echo "Removing existing database files located at $POSTGRES_DIR"
  rm -rf "$POSTGRES_DIR/data"
  rm -f "$POSTGRES_DIR/.s.PGSQL.$PGPORT"
fi

# setup db
if [ ! -e "$POSTGRES_DIR/data" ]; then
  mkdir -p "$POSTGRES_DIR/data"
  initdb -D "$POSTGRES_DIR/data" --encoding=UTF8 --locale=en_US.UTF-8 -A trust -U "$PGUSER"
fi

# start postgres
postgres -D "$POSTGRES_DIR/data" -k "$POSTGRES_DIR" > "$POSTGRES_DIR/postgres.log" 2>&1 &
PSQL_PID="$!"
sleep 5
cat "$POSTGRES_DIR/postgres.log"
echo
ps -f "$PSQL_PID"
