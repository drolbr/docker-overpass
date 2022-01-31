#!/usr/bin/env bash

PROC_UID=$(id -u)
DB_UID=$(stat -c '%u' /overpass/db)

if [[ $PROC_UID -eq 0 ]]; then
  if [[ $DB_UID -eq 0 ]]; then
    echo "SECURITY PANIC: the owner of the database directory is root"
    exit 0
  fi
  adduser --uid $DB_UID --disabled-password overpass
  su overpass ./run.sh &
  RUN_PID=$!
elif [[ $DB_UID -ne $PROC_UID ]]; then
  echo "The user of run.sh does not match the user of the database directory"
  exit 0
else
  cd /overpass
  bin/dispatcher --osm-base --db-dir=db/ &
  export OVERPASS_DB_DIR=/overpass/db/
  sleep 1
  bin/fetch_osc_and_apply.sh https://planet.osm.org/replication/minute &
fi  

shutdown()
{
  if [[ $PROC_UID -eq 0 ]]; then
    cd /overpass
    kill $RUN_PID
    wait
  else
    echo "Overpass user stops the dispatcher"
    cd /overpass
    bin/dispatcher --osm-base --terminate
    rm db/*.lock
    exit 0
  fi
};

trap shutdown SIGTERM

wait

