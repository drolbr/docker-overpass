#!/usr/bin/env bash

#wget https://dev.overpass-api.de/releases/osm-3s_v0.7.57.tar.gz
gunzip <osm-3s_v0.7.57.tar.gz | tar x
BUILD_DIR=$(gunzip <osm-3s_v0.7.57.tar.gz | tar t | head -n 1)

mkdir -p overpass
mv "$BUILD_DIR/html" overpass/

pushd "$BUILD_DIR"
./configure --disable-dependency-tracking --enable-lz4 --prefix="$(pwd)/../overpass"
make -j 2
make install
popd

pushd overpass
mkdir -p db
strip bin/*
strip cgi-bin/*
popd

