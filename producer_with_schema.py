#!/usr/bin/env python3

from schema_registry.client import SchemaRegistryClient, schema
from schema_registry.serializers import MessageSerializer
from kafka import KafkaProducer

TOPIC_NAME = 'kavro-test'

client = SchemaRegistryClient("http://127.0.0.1:8081")
message_serializer = MessageSerializer(client)

avro_schema = schema.AvroSchema({
    "type": "record",
    "namespace": "com.example",
    "name": "AvroUsers",
    "fields": [
        {"name": "first_name", "type": "string"},
        {"name": "last_name", "type": "string"},
        {"name": "age", "type": "int"},

    ],
})

user_record = {
    "first_name": "Foo",
    "last_name": "Bar",
    "age": 99,
}

message_encoded = message_serializer.encode_record_with_schema(
    "kavrotest", avro_schema, user_record)

producer = KafkaProducer(bootstrap_servers=['127.0.0.1:9092'],
                         api_version=(0, 10))

producer.send(TOPIC_NAME, value=message_encoded)
producer.flush()

print('Encoded message has been flushed to Kafka')
