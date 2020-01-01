#!/bin/bash
set -euo pipefail

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
confluent-5.3.2/bin/zookeeper-server-start confluent-5.3.2/etc/kafka/zookeeper.properties > zookeeper.log 2>&1 &
PID_ZOOKEEPER="$!"

echo "Starting Kafka"
confluent-5.3.2/bin/kafka-server-start confluent-5.3.2/etc/kafka/server.properties > kafka.log 2>&1 &
PID_KAFKA="$!"

poll "Waiting for Kafka to be fully up" lsof -i:9092
echo "Starting Schema Registry"
confluent-5.3.2/bin/schema-registry-start confluent-5.3.2/etc/schema-registry/schema-registry.properties > schema-registry.log 2>&1 &
PID_REGISTRY="$!"

echo "All services running"

trap ctrl_c INT

function ctrl_c() {
  echo
  echo "Killing all processes"
  kill -9 "$PID_REGISTRY" || true
  kill -9 "$PID_KAFKA" || true
  kill -9 "$PID_ZOOKEEPER" || true
  echo "Done!"
}

wait
