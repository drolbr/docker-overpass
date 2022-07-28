#!/usr/bin/env bash

OVERPASS_VERSION=0.7.58

wget https://dev.overpass-api.de/releases/osm-3s_v${OVERPASS_VERSION}.tar.gz
gunzip <osm-3s_v${OVERPASS_VERSION}.tar.gz | tar x
BUILD_DIR="$(pwd)/$(gunzip <osm-3s_v${OVERPASS_VERSION}.tar.gz | tar t | head -n 1)"

mkdir -p overpass

pushd "$BUILD_DIR"
./configure --disable-dependency-tracking --enable-lz4 --prefix="$(pwd)/../overpass"
make -j 2
make install
cp -pR rules/ "$(pwd)/../overpass/"
popd

pushd overpass
mkdir -p db
strip bin/*
strip cgi-bin/*
popd

