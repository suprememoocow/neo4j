neo4j
=====

Neo4j is a highly scalable, robust (fully ACID) native graph database. Neo4j is used in mission-critical apps by thousands of leading, startups, enterprises, and governments around the world.

With the Dockerfile on repository you've a docker neo4j community edition image ready to go.

### Environment variables

 * JVM_INIT_MEMORY: `-Xms` value in MB. default 2048
 * JVM_MAX_MEMORY: `-Xmx` value in MB. default 4096
 * AUTH_ENABLED: `true` or `false`. Defaults to false
 * JMX_ENABLED: `true` if you would like the server to expose JMX
   * JMX_PORT: port for JMX (defaults to 13637)
   * JMX_REQUIRE_AUTH: require username and password for JMX (defaults to true)

### Setup

1. Execute this command:

	`docker run -i -t -d --name neo4j --cap-add=SYS_RESOURCE -p 7474:7474 suprememoocow/neo4j`

2. Access to http://localhost:7474 with your browser.


### To expose JMX
`docker run -i -t -d --name neo4j --cap-add=SYS_RESOURCE -p 7474:7474 -p 13637:13637 -e JMX_ENABLED=true suprememoocow/neo4j`
