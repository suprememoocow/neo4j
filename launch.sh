#!/bin/bash

NEO4J_HOME=/var/lib/neo4j
NEO4J_SERVER_PROPS=$NEO4J_HOME/conf/neo4j-server.properties
NEO4J_PROPS=$NEO4J_HOME/conf/neo4j.properties

cat <<EOD > $NEO4J_PROPS
allow_store_upgrade=true
#dbms.pagecache.memory=10g
cache_type=soft
wrapper.java.initmemory=${JVM_INIT_MEMORY-2048}
wrapper.java.maxmemory=${JVM_MAX_MEMORY-12228}
keep_logical_logs=false
remote_shell_enabled=true
remote_shell_host=0.0.0.0
EOD

cat <<EOD > $NEO4J_SERVER_PROPS
org.neo4j.server.database.location=/opt/data/graph.db
org.neo4j.server.db.tuning.properties=conf/neo4j.properties
org.neo4j.server.webserver.address=0.0.0.0
dbms.security.auth_enabled=${AUTH_ENABLED-false}
org.neo4j.server.webserver.port=7474
org.neo4j.server.webserver.https.enabled=false
# org.neo4j.server.webserver.https.port=7473
# org.neo4j.server.webserver.https.cert.location=conf/ssl/snakeoil.cert
# org.neo4j.server.webserver.https.key.location=conf/ssl/snakeoil.key
# org.neo4j.server.webserver.https.keystore.location=data/keystore
org.neo4j.server.http.log.enabled=false
org.neo4j.server.http.log.config=conf/neo4j-http-logging.xml
org.neo4j.server.webadmin.rrdb.location=/opt/data/graph.db/rrd
EOD

# doing this conditionally in case there is already a limit higher than what
# we're setting here. neo4j recommends at least 40000.
#
# (http://neo4j.com/docs/1.6.2/configuration-linux-notes.html#_setting_the_number_of_open_files)
limit=`ulimit -n`
if [ "$limit" -lt 65536 ]; then
    ulimit -n 65536;
fi

.$NEO4J_HOME/bin/neo4j console
