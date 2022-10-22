#!/usr/bin/env bash

cat /usr/local/apache2/conf/httpd.conf | awk \
  '{ print; if ($1 == "ScriptAlias" && !inserted) { print "ScriptAlias /api/ \"/overpass/cgi-bin/\""; inserted = 1; } }' >_

echo '<Directory "/overpass/cgi-bin">' >>_
echo '    AllowOverride None' >>_
echo '    Options None' >>_
echo '    Require all granted' >>_
echo '    SetEnv OVERPASS_DB_DIR "/overpass/db/"' >>_
echo '</Directory>' >>_

mv _ /usr/local/apache2/conf/httpd.conf
