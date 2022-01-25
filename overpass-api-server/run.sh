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
fi  

shutdown()
{
  if [[ $PROC_UID -eq 0 ]]; then
    cd /overpass
    ls -l bin/dispatcher
    kill $RUN_PID
    wait
  else
    cd /overpass
    ls -l 
    bin/dispatcher --osm-base --terminate
    exit 0
  fi
};

trap shutdown SIGTERM

wait

