# Unison in Docker

This repository distributes [unison](https://github.com/bcpierce00/unison) in a Dockerfile intended to synchronize two different volumes of a containerized cluster (Kubernetes, Docker Swarm, etc).

## Key takeway

1. One container in `server` mode linked to host 1
2. One container in `client` mode linked to host 2
3. Both containers with the volumes to sync attached to `/data` respectively

## Unison?

From the original developer
> Unison is a file-synchronization tool for POSIX-compliant systems[...]. It allows two replicas of a collection of files and directories to be stored on different hosts (or different disks on the same host), modified separately, and then brought up to date by propagating the changes in each replica to the other.

Furthermore
> Unison has been in use for over 20 years and many people use it to synchronize data they care about.

## Rational

There are many synchronization tools aimed at keeping remote file systems or directories in sync. This is a very sensible topic because:

1. having *fast* local operations when using distributed filesystems is difficult or even impossible
2. choosing between those tools really depends on the workload of the environment it is being deployed in

While for heavy workloads and where concurrency is required, tools like [GlusterFS](http://www.gluster.org/), [BindFS](http://bindfs.org/) or [DRBD](http://www.drbd.org/) are required, for many other workloads (e.g. keeping two volumes in sync where changes are infrequent) there are simpler solutions!

That's where tools like [unison](https://github.com/bcpierce00/unison) and [lsyncd](https://github.com/lsyncd/lsyncd) come in handy. Stability, predictability, and easy setup are some of the reasons we ended up choosing unison.

## Caveats

1. This is **not** a solution for workloads where files are constantly changing (probably this tool will run into file conflicts and you'll end up in a mess...)
2. Most of the time you just want to have one instance *using* the files. Concurrent changes can generate file conflicts, as above.

## When to use

Workloads where changes are infrequent and ultimately you only need to keep two volumes in sync.

Some solutions this tool can provide:

### High-availability WordPress
In the world of containerization, stateless is king! Unfortunately, some applications like [WordPress](https://wordpress.org/) change their source code during runtime because of the automatic updates or when a user installs themes or plugins.

One way to achieve high-availability is to have two hosts in different regions running a scheduler (e.g. Docker Swarm or Kubernetes) and deploy WordPress on both hosts.

But they need to stay in sync, right? If you expose the WordPress root folder on one volume, it's easy to sync the two servers using this image.

In order not to have problems (like WordPress disabling plugins because they don't exist in one of the hosts or WordPress was recently upgraded) it's important to know that you should run **only one** instance of WordPress at a time. This is due to its inherent behaviour (believe us, we've been down that road before, it's not great...).

So, if the node WordPress is running on stops serving users, the scheduler will start a new instance on the other node, which will lead to a few seconds of downtime... unfortunately, that's the most you can get without get into conflicts and WordPress issues.

1. Deploy this image to both hosts, one being the `server` and the other a `client` (it doesn't matter which one, they will play nice to each other)
2. Attach a volume to each one and map it to `/data`. You can find an example in the [`examples`](./examples/) folder.
3. Attach a WordPress container to the same volume where the root folder is the volume.
4. Now, if all went well, both volumes should have the WordPress source code and whenever changes are made they will stay in sync.

*Note: take a look at [moveyourdigital/docker-wordpress-fpm](moveyourdigital/docker-wordpress-fpm) for ways to replicate MySQL using MariaDB Maxscale.*

### Embedded / File-based databases

Some applications use files as their databases, like [Bolt](https://github.com/boltdb/bolt). This is the case with [Portainer](https://github.com/portainer/portainer). To achieve high-availability in the case of one of the hosts is down, you can expose the database file to a volume and use that image to perform the synchronizations.

1. Deploy this image to both hosts, one being the `server` and the other a `client` (it doesn't matter which one)
2. Attach the volume to each and map to `/data`.
3. Attach the same volume to the directory where the application saves the database file.
4. Now, if all went well, both volumes should have the file synced.

## Usage

Use [docker-compose.yml](./docker-compose.yml) to get an idea of how to use this image.
See the [examples](./examples) folder for common implementations.
