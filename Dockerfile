FROM postgres:9.4
RUN apt-get update -y && apt-get install -y --no-install-recommends postgresql postgresql-server-dev-9.4 build-essential pkg-config protobuf-compiler libprotobuf-c-dev
COPY ./ /decoderbufs
WORKDIR /decoderbufs
RUN make && make install && rm -rf /decoderbufs
RUN echo "shared_preload_libraries = 'decoderbufs'" >>/usr/share/postgresql/postgresql.conf.sample
RUN echo "wal_level = logical" >>/usr/share/postgresql/postgresql.conf.sample
RUN echo "max_wal_senders = 8" >>/usr/share/postgresql/postgresql.conf.sample
RUN echo "wal_keep_segments = 4" >>/usr/share/postgresql/postgresql.conf.sample
RUN echo "max_replication_slots = 4" >>/usr/share/postgresql/postgresql.conf.sample
RUN echo "local  replication all trust" >>/usr/share/postgresql/9.4//pg_hba.conf.sample
RUN echo "host   replication all 0.0.0/0 trust" >>/usr/share/postgresql/9.4/pg_hba.conf.sample
RUN echo "host   replication all ::/0 trust" >>/usr/share/postgresql/9.4/pg_hba.conf.sample
