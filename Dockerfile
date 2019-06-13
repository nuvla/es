FROM docker.elastic.co/elasticsearch/elasticsearch:7.0.0

RUN bin/elasticsearch-plugin install --batch repository-s3

ADD nuvla-init.sh /usr/local/bin/nuvla-init.sh
RUN chmod a+x /usr/local/bin/nuvla-init.sh

ENTRYPOINT /usr/local/bin/nuvla-init.sh
