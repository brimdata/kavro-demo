#!/bin/bash
set -euo pipefail

URL='http://packages.confluent.io/archive/5.3/confluent-5.3.2-2.12.tar.gz'
PACKAGE=$(echo "$URL" | sed 's/.*\///')
DIR="confluent-5.3.2"
curl -O "$URL"
tar xzvf "$PACKAGE"
perl -i -pe "s/zookeeper.connect=localhost:2181/zookeeper.connect=127.0.0.1:2181/" "$DIR"/etc/kafka/server.properties
perl -i -pe "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/127.0.0.1:9092/" "$DIR"/etc/kafka/server.properties
