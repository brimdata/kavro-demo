#!/bin/bash
set -euo pipefail

DIR="confluent-5.3.2"

function poll {
    # Poll until a condition is reached. The condition must be a
    # command. After a minute, bail.
    # Args:
    # First positional: Message to print while polling. This must be
    # quoted.
    # Other positionals: The condition to poll.
    # Example usage:
    # poll "Waiting for file foo to appear" test -f foo
    message="$1"
    shift
    delay=0.1
    total=60
    start=$(date +"%s")
    until "$@" > /dev/null
    do
        elapsed=$(date +"%s")
        if (( elapsed - start > total ))
        then
            echo "Condition $* never met"
            exit 1
        fi
        echo "${message}"
        sleep ${delay}
    done
}

echo "Starting Zookeeper"
"$DIR"/bin/zookeeper-server-start "$DIR"/etc/kafka/zookeeper.properties > zookeeper.log 2>&1 &
PID_ZOOKEEPER="$!"
echo "Zookeeper PID: $PID_ZOOKEEPER"

echo "Starting Kafka"
"$DIR"/bin/kafka-server-start "$DIR"/etc/kafka/server.properties > kafka.log 2>&1 &
PID_KAFKA="$!"
echo "Kafka PID: $PID_KAFKA"

poll "Waiting for Kafka to be fully up" lsof -i:9092
echo "Starting Schema Registry"
"$DIR"/bin/schema-registry-start "$DIR"/etc/schema-registry/schema-registry.properties > schema-registry.log 2>&1 &
PID_REGISTRY="$!"
echo "Schema Registry PID: $PID_REGISTRY"

poll "Waiting for Schema Registry to be fully up" lsof -i:8081

# Steve's research found this setting was necessary for our use case.
echo "Adding the Schema registry setting to allow different schemas on a topic"
curl -X PUT -H "Content-Type: application/vnd.schemaregistry.v1+json" \
    --data '{"compatibility": "NONE"}' \
    http://localhost:8081/config

echo -e "\nAll services running ($PID_ZOOKEEPER $PID_KAFKA $PID_REGISTRY)"

trap ctrl_c INT

function ctrl_c() {
  echo
  "$DIR"/bin/schema-registry-stop
  echo "Waiting for Schema Registry to fully stop" 
  wait "$PID_REGISTRY" || true
  "$DIR"/bin/kafka-server-stop
  echo "Waiting for Kafka to fully stop"
  wait "$PID_KAFKA" || true
  echo "Waiting for Zookeeper to fully stop"
  "$DIR"/bin/zookeeper-server-stop
  wait "$PID_ZOOKEEPER" || true
  echo "Done!"
}

wait
