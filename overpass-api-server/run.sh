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
  if [[ ! -f /overpass/db/replicate_id && "${init_from_clone}" == "geo" ]]; then
    bin/download_clone.sh --db-dir=/overpass/db --source=https://dev.overpass-api.de/api_drolbr/ --meta=no
  elif [[ ! -f /overpass/db/replicate_id && "${init_from_clone}" == "meta" ]]; then
    bin/download_clone.sh --db-dir=/overpass/db --source=https://dev.overpass-api.de/api_drolbr/ --meta=yes
  elif [[ ! -f /overpass/db/replicate_id && "${init_from_clone}" == "attic" ]]; then
    bin/download_clone.sh --db-dir=/overpass/db --source=https://dev.overpass-api.de/api_drolbr/ --meta=attic
  fi
  bin/dispatcher --osm-base --db-dir=db/ &
  export OVERPASS_DB_DIR=/overpass/db/
  sleep 1
  bin/fetch_osc_and_apply.sh https://planet.osm.org/replication/minute &
  if [[ "${overpass_areas}" == "yes" ]]; then
    if [[ ! -d db/rules/ ]]; then
      cp -pR rules/ db/
    fi
    bin/dispatcher --areas --db-dir=db/ &
    bin/rules_delta_loop.sh $OVERPASS_DB_DIR &
  fi
fi  

shutdown()
{
  if [[ $PROC_UID -eq 0 ]]; then
    cd /overpass
    kill $RUN_PID
    wait
  else
    cd /overpass
    bin/dispatcher --osm-base --terminate
    bin/dispatcher --areas --terminate
    rm -f db/*.lock
    exit 0
  fi
};

trap shutdown SIGTERM

wait

