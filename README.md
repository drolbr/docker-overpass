
# Docker Container for the Overpass API

This is a collection of Docker containers to run the Overpass API ([documentation](https://dev.overpass-api.de/overpass-doc/en/), [source code](https://github.com/drolbr/Overpass-API)),
written by a maintainer of the Overpass API.

## Usage

To use these containers, build them with

    pushd overpass-api-server/
    docker build -t osm3s-server .
    popd
    
    pushd overpass-api-httpd/
    docker build -t osm3s-httpd .
    popd

Then, run the server container. If you need to download a copy of the OSM data, then you can do so:

    docker run -d --name overpass-server -v $DB_DIR:/overpass/db -e init_from_clone=geo osm3s-server

Warning: these are hundreds of gigabyte of data, so it will take some time and need a lot of space in the `$DB_DIR` directory.
To avoid accidential downloads, the download is only started if there is no file `replicate_id` in the `$DB_DIR` directory.
In a populated database, the file indicates the id from which the files have been replicated.
Thus, its absence means that the existing data, if any, is dubious.

There are also parameter values to download including the meta data (`meta`) or the full database history (`attic`).

If you have already a Overpass database prepopulated, then you can start it directly:

    docker run -d --name overpass-server -v $DB_DIR:/overpass/db osm3s-server
    
Areas need some extra computation steps.
Thus they must be activated by setting an environment variable with `-e overpass_areas=yes`.
The setting can be combined with the clone setting.

As a next step, run the frontend container with `$DB_DIR` set to your database directory:
    
    docker run -d --name overpass-httpd -p 8080:80 -v $DB_DIR:/overpass/db osm3s-httpd

Finally, before offering this service over the open internet,
ensure that you proxy the webserver on port 8080 via HTTPS.
For the moment being, I do not know which configurations for Let's Encrypt or other CAs exist out there,
thus there is no direct support for HTTPS in the container yet.
