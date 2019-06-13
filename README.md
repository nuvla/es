# Elasticsearch for Nuvla

This repository provides a customized Elasticsearch container that
allows backups to S3. This can be used as a drop-in replacement for
the standard Elasticsearch container.

The versions follow the Elasticsearch version, with an extra field
that tracks modifications to the customized container. For example,
version 7.0.0.3 would be the fourth version of this container based on
Elasticsearch 7.0.0.

To configure backups to S3 for the container(s), provide a
configuration similar to the following in your `docker-compose.yml`
file:

```
version: '3.3'

secrets:
  s3_access_key:
    file: ./secrets/s3_access_key
  s3_secret_key:
    file: ./secrets/s3_secret_key

services:
  es:
    image: nuvla/es
    environment:
      - cluster.name=elasticsearch
      - xpack.security.enabled=false
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
    secrets:
      - s3_access_key
      - s3_secret_key
    volumes:
      - esdata:/usr/share/elasticsearch/data

volumes:
  esdata:
    driver: local
```


When deploying, add your S3 access and secret keys to the referenced
files in the `secrets` subdirectory.  The files will appear in
`/run/secrets/` inside the container.

After the Elasticsearch container has been deployed, you must add a
repository definition to the database. Do the following:

```sh
curl -X PUT "localhost:9200/_snapshot/s3_backup" \
     -H 'Content-Type: application/json' -d @repo.json
```

where the file contains:

```json
{
    "type" : "s3",
    "settings" : {
        "bucket" : "nuvla-es-backup",
        "endpoint" : "sos-ch-dk-2.exo.io"
    }
}

```

The "settings" map must contain the configuration parameters for your
S3 service. **Note that the S3 bucket must exist before you can add
this definition to Elasticsearch.**

To trigger a snapshot, use the command:

```sh
curl -X PUT "localhost:9200/_snapshot/s3_backup/snapshot_1?wait_for_completion=true"
```

It is recommended to use names based on dates for the snapshot
("snapshot_1") names.

The easiest way of doing periodic backups is to add a cron entry to
the Docker host.  An example of such a script is:

```sh
#!/bin/bash

export LANG=en_US.utf8

set -e

CONFIG=/etc/nuvla/nuvla-es-backup.conf

source $CONFIG

BACKUP_TIMESTAMP=${BACKUP_TIMESTAMP:-"/var/log/nuvla-es-backup-timestamp"}

# Note that snapshot name must be lowercase (required by ES).
BACKUP_NAME=snapshot.$(date --utc "+%Y-%m-%dt%H%Mz")

ES="${ES_HOST-localhost}:${ES_PORT-9200}"
set +e
output=$(curl -sSf -XPUT http://$ES/_snapshot/s3_backup/$BACKUP_NAME?wait_for_completion=true 2>&1)
rc=$?
set -e
if [ "$rc" -eq "0" ]; then
    echo "Nuvla ES Backup Successful. $BACKUP_NAME. $output"
    touch ${BACKUP_TIMESTAMP}
else
    echo "FAILURE $BACKUP_NAME: $output"
fi
exit $rc
```

Generally, the `/etc/nuvla/nuvla-es-backup.conf` configuration file
will not be needed, but can contain the following fields:

```sh
ES_HOST=159.100.243.234
ES_PORT=9200
BACKUP_TIMESTAMP=/var/log/nuvla/nuvla-backup-timestamp
```

If you do not have access to the host running Elasticsearch, then you
can create a container to run the above script within the Docker
cluster.
