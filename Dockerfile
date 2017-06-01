FROM postgres:9.6

ENV WORKDIR /decoderbufs
ENV PSQLDIR /usr/share/postgresql/9.6

WORKDIR $WORKDIR

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libprotobuf-c-dev \
      pkg-config \
      postgresql \
      postgresql-server-dev-9.6 \
      protobuf-compiler

COPY . .

RUN make && make install && rm -rf $WORKDIR

RUN apt-get purge -y \
      build-essential \
      libprotobuf-c-dev \
      pkg-config \
      postgresql \
      postgresql-server-dev-9.6 \
      protobuf-compiler

RUN echo "\n\
    shared_preload_libraries = 'decoderbufs' \n\
    wal_level = logical \n\
    max_wal_senders = 8 \n\
    wal_keep_segments = 4 \n\
    max_replication_slots = 4 \n\
    " >> $PSQLDIR/postgresql.conf.sample && \
    echo "\n\
    local  replication all trust \n\
    host   replication all 0.0.0/0 trust \n\
    host   replication all ::/0 trust \n\
    " >> $PSQLDIR/pg_hba.conf.sample

HEALTHCHECK --interval=1m --timeout=5s \
  CMD psql -U postgres "dbname=postgres replication=database" -c "IDENTIFY_SYSTEM;" || exit 1
