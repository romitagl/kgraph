# HASURA

This folder contains the Postgresql database and Graphql Engine files.

## Dependencies

All the services run in a **Docker** container and are orchestrated through [Docker Compose](https://docs.docker.com/compose/).

**GNU make**, **jq**, **curl** and **nc** are also required for running the tests.

## Setup

Set the required environment variables:

```bash
# set the admin secret for Hasura - can be generated random: `openssl rand -base64 32`
export HASURA_GRAPHQL_ADMIN_SECRET="hasura-admin-secret"
# set the Hasura JWT secret as described at: https://hasura.io/docs/latest/graphql/core/auth/authentication/jwt.html, https://hasura.io/docs/latest/graphql/core/actions/codegen/python-flask.html#actions-codegen-python-flask
export HASURA_GRAPHQL_JWT_SECRET_TYPE='HS256'
# set the JWT secret key for Hasura - can be generated random: `openssl rand -base64 68`
export HASURA_GRAPHQL_JWT_SECRET_KEY=$(openssl rand -base64 68)
export HASURA_GRAPHQL_JWT_SECRET="{ \"type\": \"${HASURA_GRAPHQL_JWT_SECRET_TYPE}\", \"key\": \"${HASURA_GRAPHQL_JWT_SECRET_KEY}\" }"
# Set to "true" to enable the Hasura GraphQL console (development). Set to "false" for production.
export HASURA_GRAPHQL_ENABLE_CONSOLE="true"
```

Quick Run:

```bash
# only for first setup or when re-setting the schema
make dependencies
# to start the GraphQL Server
make start
# install the PostgreSQL schema and Hasura metadata
make install_schema_and_metadata
# add default PostgreSQL configuration
make add_default_config
```

The Hasura console, if enabled (*HASURA_GRAPHQL_ENABLE_CONSOLE=true*), is available at: `http://localhost:8080/console`. Remember to select the `kgraph` Database Schema.

The following scripts are used to update an existing production environment, creating the new schema an reimporting a backup of the data.

```bash
# take a dump of the Postgres DB for full backup
bash ./utils/export-dump-hasura.sh
# export data from the Postgres DB for reimporting in the new schema
bash ./utils/export-data-hasura.sh

# (optional) - if the Postgres schema/Hasura metadata have changed
bash ./utils/export-metadata-hasura.sh
bash ./utils/export-schema-hasura.sh

# stop the GraphQL engine
make stop
# remove the Postgresql folder
make dependencies

# (optional) - if the Postgres schema/Hasura metadata have changed
mv ./schema/hasura-metadata-dump-exported.json ./schema/hasura-metadata-dump.json
mv ./schema/hasura-schema-dump-exported.sql ./schema/hasura-schema-dump.sql

# import the sql schema, metadata and data
make start
make install_schema_and_metadata
make add_default_config
bash ./utils/import-data-hasura.sh
```

## Testing

The Makefile implements all the targets required for an End-To-End testing in particular:

1. Satisfy the required dependencies
2. Start the graphql-engine and postgresdb
3. Install the SQL schema and the Hasura metadata
4. Run all the tests available
5. Stop the Docker containers

To run the tests: `make ci`

## Developer Notes

- Hasura Metadata export: `bash ./utils/export-metadata-hasura.sh`. Metadata are saved into the *schema/hasura-metadata-dump-exported.json* file
- SQL Schema export: run `bash ./utils/export-schema-hasura.sh`. Schema is exported to the *schema/hasura-schema-dump-exported.sql* file (folder shared as docker-compose volume)
- SQL Data export: run `bash ./utils/export-data-hasura.sh`. SQL Data is exported to the *schema/hasura-data-exported.sql* file (folder shared as docker-compose volume)
- SQL Full Dump export: run `bash ./utils/export-dump-hasura.sh`. SQL Data is exported to the *schema/hasura-dump-exported.sql* file (folder shared as docker-compose volume)
- Authentication service build: `docker-compose build auth-service`, to follow the logs: `docker-compose logs -f auth-service`

### Postgresql debugging commands

Connect to the postgres container: `docker-compose exec postgres sh`

```bash
# login using the postgres user
psql -U postgres

# display commands help
postgres-# \?

# display user roles
postgres=# \du

# show Postgres configuration file named pg_hba.conf 
postgres=# show hba_file;
# reload the configuration file while Postgres is running
postgres=# SELECT pg_reload_conf();

# list databases
postgres=# \l+
# connect to a database
postgres=# \c database_name
# list schemas
postgres-# \dn+
# list current schema
postgres=# SHOW search_path;
# set a schema
postgres=# SET search_path TO target_schema;
# display tables:
postgres=# \dt
# if want to see schema tables
postgres=# \dt+
# display columns of a table
postgres=# \d+ table_name
# select first row from a table
postgres=# SELECT * FROM table_name LIMIT 1;
# count the records in a table
postgres=# SELECT COUNT(*) FROM table_name;
# select last row from a table (row count -1)
postgres=# SELECT * FROM table_name OFFSET row_number ROWS;

# Stop
pg_ctl stop

# Start
pg_ctl start
```

### Docker

#### Volumes

Docker page: <https://docs.docker.com/storage/volumes/>

```bash
docker volume ls
docker volume inspect ${volume_name}
```

Volumes are useful for backups, restores, and migrations. Use the *--volumes-from* flag to create a new container that mounts that volume.

**Backup a container volume**:

- `docker run -v /dbdata --name dbstore ubuntu /bin/bash`: for example, create a new container named dbstore.
- `docker run --rm --volumes-from dbstore -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata`: launch a new container and mount the volume from the dbstore container, mount a local host directory as /backup, pass a command that tars the contents of the dbdata volume to a backup.tar file inside our /backup directory.
- when the command completes and the container stops, we are left with a backup of our dbdata volume.

**Restore a container volume**:

- `docker run -v /dbdata --name dbstore2 ubuntu /bin/bash`: for example, create a new container named dbstore2.
- `docker run --rm --volumes-from dbstore2 -v $(pwd):/backup ubuntu bash -c "cd /dbdata && tar xvf /backup/backup.tar --strip 1"`: un-tar the backup file in the new container`s data volume.
- the techniques above can be used to automate backup, migration and restore testing using your preferred tools.

#### Logging

Docker page: <https://docs.docker.com/config/containers/logging/configure/>

#### Metrics

Runtime options with Memory, CPUs, and GPUs: <https://docs.docker.com/config/containers/resource_constraints/>.

Metrics pseudo-files are located in */sys/fs/cgroup* in the host OS. In some systems, they may be in */cgroup* instead.

```bash
# to get the container id use: docker ps
docker stats <container_id>
```

##### CPU

| Name | Description | Metric type |
| :--- | :--- | --- |
| user CPU | Percent of time that CPU is under direct control of processes | Resource: Utilization |
| system CPU | Percent of time that CPU is executing system calls on behalf of processes | Resource: Utilization |
| throttling (count) | Number of CPU throttling enforcements for a container | Resource: Saturation |
| throttling (time)| Total time that a container's CPU usage was throttled| Resource: Saturation |

```bash
# /sys/fs/cgroup/cpuacct/docker/$CONTAINER_ID/
# usage
cat /sys/fs/cgroup/cpuacct/docker/$CONTAINER_ID/cpuacct.stat
# usage per core
cat /sys/fs/cgroup/cpuacct/docker/$CONTAINER_ID/cpuacct.usage_percpu
# multiple CPU
cat /sys/fs/cgroup/cpuacct/docker/$CONTAINER_ID/cpuacct.usage
# throttled CPU
cat /sys/fs/cgroup/cpu/docker/$CONTAINER_ID/cpu.stat
```

##### Memory

| Name | Description | Metric type |
| :--- | :--- | --- |
| Memory | Memory usage of a container| Resource: Utilization |
| RSS | Resident set size is data that belongs to a process (stacks, heaps, etc.) | Resource: Utilization |
| Cache memory | Data from disk cached in memory | Resource: Utilization |
| Swap | Amount of swap space in use | Resource: Saturation |

```bash
# memory
cat /sys/fs/cgroup/memory/docker/$CONTAINER_ID/memory.stat
# total memory used: cached + rss
$ cat /sys/fs/cgroup/memory/docker/$CONTAINER_ID/memory.usage_in_bytes
# total memory used + swap in use
$ cat /sys/fs/cgroup/memory/docker/$CONTAINER_ID/memory.memsw.usage_in_bytes
# number of times memory usage hit limts
$ cat /sys/fs/cgroup/memory/docker/$CONTAINER_ID/memory.failcnt
# memory limit of the cgroup in bytes
$ cat /sys/fs/cgroup/memory/docker/$CONTAINER_ID/memory.limit_in_bytes
```

To set a 500MB limit, for example: `docker run -m 500M IMAGE [COMMAND] [ARG...]`

##### I/O

For each block device, Docker reports the following two metrics, decomposed into four counters: by reads versus writes, and by synchronous versus asynchronous I/O.

| Name | Description | Metric type |
| :--- | :--- | --- |
| I/O serviced | Count of I/O operations performed, regardless of size | Resource: Utilization |
| I/O service bytes | Bytes read or written by the cgroup | Resource: Utilization |

The path to I/O stats pseudo-files for most operating systems is: */sys/fs/cgroup/blkio/docker/$CONTAINER_ID/*.

Depending on your system, you may have many metrics available from these pseudo-files: blkio.io_queued_recursive, blkio.io_service_time_recursive, blkio.io_wait_time_recursive and more.

On many systems, however, many of these pseudo-files only return zero values. In this case there are usually still two pseudo-files that work: blkio.throttle.io_service_bytes and blkio.throttle.io_serviced, which report total I/O bytes and operations, respectively. Contrary to their names, these numbers do not report throttled I/O but actual I/O bytes and ops.

##### Network

Just like an ordinary host, Docker can report several different network metrics, each of them divided into separate metrics for inbound and outbound network traffic:

| Name | Description | Metric type |
| :--- | :--- | --- |
| Bytes | Network traffic volume (send/receive) | Resource: Utilization |
| Packets | Network packet count (send/receive) | Resource: Utilization |
| Errors (receive) | Packets received with errors | Resource: Error |
| Errors (transmit) | Errors in packet transmission | Resource: Error |
| Dropped | Packets dropped (send/receive) | Resource: Error |

```bash
CONTAINER_PID=`docker inspect -f '{{ .State.Pid }}' $CONTAINER_ID`
cat /proc/$CONTAINER_PID/net/dev
```

##### GPU

NVIDIA - CUDA: <https://github.com/NVIDIA/nvidia-docker/wiki/CUDA>.

EXPOSE GPUS FOR USE
Include the --gpus flag when you start a container to access GPU resources. Specify how many GPUs to use. For example: `docker run -it --rm --gpus all ubuntu nvidia-smi`.

##### API

Docker page: <https://docs.docker.com/engine/api/>

Like the docker stats command, the API will continuously report a live stream of CPU, memory, I/O, and network metrics. The difference is that the API provides far more detail than the stats command.

The daemon listens on *unix:///var/run/docker.sock* to allow only local connections by the root user.

- List and manage containers: `curl --unix-socket /var/run/docker.sock http://localhost/v1.41/containers/json`
- To collect all metrics in a continuously updated live stream of JSON: `curl --unix-socket /var/run/docker.sock http://localhost/v1.41/containers/$CONTAINER_ID/stats`
