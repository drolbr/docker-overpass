#!/usr/bin/env bash

pushd /overpass >/dev/null
bin/dispatcher --osm-base --attic --db-dir=db/ &
popd >/dev/null

shutdown()
{
  echo "Shutdown ..."
  pushd /overpass >/dev/null
  bin/dispatcher --osm-base --terminate
  popd >/dev/null
  echo "  ... done!"
  exit 0
};

trap shutdown SIGTERM

while [[ true ]]; do
  sleep 1
done

