#!/bin/bash -xe

bin/elasticsearch-keystore create

if [ -f "/var/run/secrets/s3_access_key" ]; then
  cat /run/secrets/s3_access_key | bin/elasticsearch-keystore add --stdin s3.client.default.access_key
fi

if [ -f "/var/run/secrets/s3_secret_key" ]; then
  cat /run/secrets/s3_secret_key | bin/elasticsearch-keystore add --stdin s3.client.default.secret_key
fi

bin/elasticsearch-keystore list

/usr/local/bin/docker-entrypoint.sh
