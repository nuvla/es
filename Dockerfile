FROM docker.elastic.co/elasticsearch/elasticsearch:8.11.3

RUN bin/elasticsearch-plugin install --batch repository-s3

COPY --chmod=a+x nuvla-init.sh /usr/local/bin/nuvla-init.sh

ENTRYPOINT /usr/local/bin/nuvla-init.sh
