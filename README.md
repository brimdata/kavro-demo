# kavro-demo

This repo contains a simple setup of Avro over Kafka. This includes:

* Zookeeper
* Kafka
* Schema Registry
* Test scripts

The test scripts use Python clients for Kafka and Schema Registry. One script sends a schema-fied message through Kafka as a "producer". Another then receives the message from Kafka a "consumer", unpacking and displaying it with the benefit of the schema.

With this simple end-to-end working, it's hoped the services can then be used to test our prototype that takes in richly-typed Zeek data from our [open source Zeek plugin](https://github.com/looky-cloud/zson-http-plugin) and outputs it to Kafka along with an Avro schema that we post to a [Schema Registry](https://docs.confluent.io/current/schema-registry/index.html).

# Prerequisites

You'll need `java` and `python3` installed. I've successfully tested on both Mac and Linux using the versions in the following table. It may work with others.

|**Dependency**|**Mac version**|**Linux version**|
|--------------|---------------|-----------------|
| `java`       | Java 8 Update 231 | openjdk version 11.0.5 |
| `python3`    | 3.7.4         | 3.6.9           |

# Installing services

```
./install.sh
```

This will:

* Download/unpack the community edition of [Confluent Platform](https://www.confluent.io/product/confluent-platform/)
* Modify its config files to run everything locally

# Starting services

```
./start.sh
```

This will start Zookeeper, Kafka, and Schema Registry. The script will then wait for your Control-C after which it will `kill -9` all these services. For some reason Kafka does not die easily, so I went this brute force route.

Successful start looks like:

```
# ./start.sh 
Starting Zookeeper
Starting Kafka
Waiting for Kafka to be fully up
Waiting for Kafka to be fully up
Waiting for Kafka to be fully up
Waiting for Kafka to be fully up
Waiting for Kafka to be fully up
Waiting for Kafka to be fully up
Waiting for Kafka to be fully up
Waiting for Kafka to be fully up
Waiting for Kafka to be fully up
Waiting for Kafka to be fully up
Waiting for Kafka to be fully up
Starting Schema Registry
All services running
```

If you stop the services and then run `start.sh` again, any data you'd input into Kafka or the Schema Registry should still be present.

# Clearing services

In this near-default config, Zookeeper and Kafka keep their data in `/tmp` directories. If you want to wipe these between runs so your Kafka queues are gone, the Schema Registry is emptied, etc.:

```
./clean.sh
```

Then next time you run `start.sh`, it should be the same as if you'd redone a fresh install.

# Test scripts

## Prerequisites

Create a [virtual environment](https://docs.python.org/3/tutorial/venv.html) and install dependencies.

```
python3 -m venv kavro
source kavro/bin/activate
pip3 install -r requirements.txt
```

## Running

To send a message into Kafka while simultaneously posting its schema to the registry:

```
./producer_with_schema.py 
```

To read the message back out of Kafka end decode it using its schema:

```
./consumer_with_schema.py
```

A successful run pairing looks like:

```
# ./producer_with_schema.py 
Encoded message has been flushed to Kafka

# ./consumer_with_schema.py 
{'first_name': 'Foo', 'last_name': 'Bar', 'age': 99}
```

# Containers

FWIW, I did make an attempt to create a `docker-compose` configuration to start all the services in containers. Despite having exposed my Zookeeper, Kafka, and Schema Registry ports to the host level and confirming they each responded successfully, whenever I tried to run the test scripts, they would always hang as if unable to successfully send or receive data. I spent too much time debugging this in Wireshark and never figured it out, so I just went to doing things at the host level.

# Licensing

Whereas Zookeeper and Kafka are available as ordinary Apache-licensed projects, the Schema Registry is only available from Confluent under their [Confluent Community License Agreement](https://github.com/confluentinc/schema-registry/blob/master/LICENSE-ConfluentCommunity). The tl;dr on this license is that everyone is free to use it, but you can't build SaaS-type services based on it.

Since we need stuff from Confluent, the [Confluent Platform](https://www.confluent.io/product/confluent-platform/) seems handy because it bundles all the pieces we need into one bundle. However, their [Quick Start](https://docs.confluent.io/current/quickstart/cloud-quickstart/index.html#cloud-quickstart) appears to be a trick designed to get you into their SaaS service and commercial add-ons, so I avoided it intentionally. Instead I followed their [Manual Install using ZIP and TAR Archives](https://docs.confluent.io/current/installation/installing_cp/zip-tar.html) instructions and used the Platform bundle that contains only "Confluent Community components".

# References

* [Schema Registry background](https://docs.confluent.io/current/schema-registry/index.html)
* [Manual Install of Confluent Platform](https://docs.confluent.io/current/installation/installing_cp/zip-tar.html)
* [Kafka Quickstart](https://kafka.apache.org/quickstart) (if you want to try non-Python "hello world" steps)
* [kafka-python docs](https://kafka-python.readthedocs.io/en/master/usage.html)
* [python-schema-registry-client docs](https://marcosschroh.github.io/python-schema-registry-client/)
