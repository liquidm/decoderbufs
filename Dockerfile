FROM liquidm/docker-postgresql:9.6

ENV WORKDIR /decoderbufs
ENV PSQL_CONFIG_DIR /etc/postgresql/9.6/main

ENV DB_USER=postgres
ENV DB_PASS=postgres

EXPOSE 5432

WORKDIR $WORKDIR

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libprotobuf-c-dev \
      pkg-config \
      postgresql-server-dev-9.6 \
      protobuf-compiler

COPY . .

RUN make && make install && rm -rf $WORKDIR

RUN apt-get purge -y \
      build-essential \
      libprotobuf-c-dev \
      pkg-config \
      postgresql-server-dev-9.6 \
      protobuf-compiler

RUN echo "\n\
    shared_preload_libraries = 'decoderbufs' \n\
    wal_level = logical \n\
    max_wal_senders = 8 \n\
    wal_keep_segments = 4 \n\
    max_replication_slots = 4 \n\
    " >> $PSQL_CONFIG_DIR/postgresql.conf && \
    echo "\n\
    local  replication all trust \n\
    host   replication all 0.0.0.0/0 trust \n\
    host   replication all 127.0.0.1/0 trust \n\
    host   replication all ::/0 trust \n\
    " >> $PSQL_CONFIG_DIR/pg_hba.conf

HEALTHCHECK --interval=1m --timeout=5s \
  CMD psql -U postgres "dbname=postgres replication=database" -c "IDENTIFY_SYSTEM;" || exit 1
