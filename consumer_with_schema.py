#!/usr/bin/env python3

from schema_registry.client import SchemaRegistryClient, schema
from schema_registry.serializers import MessageSerializer
from kafka import KafkaConsumer

TOPIC_NAME = 'kavro-test'

client = SchemaRegistryClient("http://127.0.0.1:8081")
message_serializer = MessageSerializer(client)

consumer = KafkaConsumer(TOPIC_NAME,
                         auto_offset_reset='earliest',
                         bootstrap_servers=['127.0.0.1:9092'],
                         api_version=(0, 10),
                         consumer_timeout_ms=1000)

for msg in consumer:
    message_decoded = message_serializer.decode_message(msg.value)
    print(message_decoded)
