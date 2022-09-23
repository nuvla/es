# Elasticsearch for Nuvla

This repository provides a customized Elasticsearch container that
includes the S3 repository plugin for saving snapshots to S3.  This
can be used as a drop-in replacement for the standard Elasticsearch
container.

The versions follow the Elasticsearch version, with an extra field
that tracks modifications to the customized container. For example,
version 7.0.0.3 would be the fourth version of this container based on
Elasticsearch 7.0.0.
