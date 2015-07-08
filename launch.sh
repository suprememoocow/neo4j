#!/bin/bash

NEO4J_HOME=/var/lib/neo4j
NEO4J_SERVER_PROPS=$NEO4J_HOME/conf/neo4j-server.properties
NEO4J_PROPS=$NEO4J_HOME/conf/neo4j.properties
NEO4J_WRAPPER=$NEO4J_HOME/conf/neo4j-wrapper.conf

cat <<EOD > $NEO4J_PROPS
allow_store_upgrade=true
#dbms.pagecache.memory=10g
cache_type=soft
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

cat <<EOD > $NEO4J_WRAPPER
wrapper.java.additional=-Dorg.neo4j.server.properties=conf/neo4j-server.properties
wrapper.java.additional=-Djava.util.logging.config.file=conf/logging.properties

wrapper.java.additional=-XX:+UseConcMarkSweepGC
wrapper.java.additional=-XX:+CMSClassUnloadingEnabled
wrapper.java.additional=-XX:-OmitStackTraceInFastThrow
wrapper.java.additional=-XX:hashCode=5

# Uncomment the following lines to enable garbage collection logging
#wrapper.java.additional=-Xloggc:data/log/neo4j-gc.log
#wrapper.java.additional=-XX:+PrintGCDetails
#wrapper.java.additional=-XX:+PrintGCDateStamps
#wrapper.java.additional=-XX:+PrintGCApplicationStoppedTime
#wrapper.java.additional=-XX:+PrintPromotionFailure
#wrapper.java.additional=-XX:+PrintTenuringDistribution

# Java Heap Size: by default the Java heap size is dynamically
# calculated based on available system resources.
# Uncomment these lines to set specific initial and maximum
# heap size in MB.
wrapper.java.initmemory=${JVM_INIT_MEMORY-2048}
wrapper.java.maxmemory=${JVM_MAX_MEMORY-4096}

#********************************************************************
# Wrapper settings
#********************************************************************
# path is relative to the bin dir
wrapper.pidfile=../data/neo4j-server.pid

#********************************************************************
# Wrapper Windows NT/2000/XP Service Properties
#********************************************************************
# WARNING - Do not modify any of these properties when an application
#  using this configuration file has been installed as a service.
#  Please uninstall the service before modifying this section.  The
#  service can then be reinstalled.

# Name of the service
wrapper.name=neo4j

# User account to be used for linux installs. Will default to current
# user if not set.
wrapper.user=

#********************************************************************
# Other Neo4j system properties
#********************************************************************
wrapper.java.additional=-Dneo4j.ext.udc.source=debian
EOD

if [[ "$JMX_ENABLED" = "true" ]]; then
  cat <<EOD >> $NEO4J_WRAPPER
wrapper.java.additional=-Dcom.sun.management.jmxremote.port=${JMX_PORT-13637}
wrapper.java.additional=-Dcom.sun.management.jmxremote.authenticate=${JMX_REQUIRE_AUTH-true}
wrapper.java.additional=-Dcom.sun.management.jmxremote.ssl=false
# wrapper.java.additional=-Dcom.sun.management.jmxremote.password.file=conf/jmx.password
# wrapper.java.additional=-Dcom.sun.management.jmxremote.access.file=conf/jmx.access
EOD
fi

echo $NEO4J_WRAPPER
cat $NEO4J_WRAPPER

# doing this conditionally in case there is already a limit higher than what
# we're setting here. neo4j recommends at least 40000.
#
# (http://neo4j.com/docs/1.6.2/configuration-linux-notes.html#_setting_the_number_of_open_files)
limit=$(ulimit -n)
if [ "$limit" -lt 65536 ]; then
    ulimit -n 65536;
fi

.$NEO4J_HOME/bin/neo4j console
