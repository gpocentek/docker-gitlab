What is GitLab?
===============

Version Control on your Server
like GitHub but Open Source

- Git repository management, code reviews, issue tracking, activity feeds, wikis and continuous integration
- 25,000 users on one server or a highly available active/active cluster, LDAP/AD group sync and audit logging
- Community driven, 700+ contributors, inspect and modify the source, easy to integrate into your infrastructure
- GitLab runs on your own servers, if you want to use it without installing, see our [free GitLab.com service](https://about.gitlab.com/gitlab-com)

<https://about.gitlab.com>


How to use this image
=====================

We assume using a data volume container, this will simplify migrations and backups. This empty container will exist to persist as volumes the 3 directories used by GitLab, so remember not to delete it.

The directories on data container are:

- `/var/opt/gitlab` for application data
- `/var/log/gitlab` for logs
- `/etc/gitlab` for configuration

Create the data container with:

```bash
sudo docker run --name gitlab_data --volume /var/opt/gitlab --volume /var/log/gitlab --volume /etc/gitlab genezys/gitlab:8.3.4 /bin/true
```

After creating this, run GitLab:

```bash
sudo docker run --detach --name gitlab_app --publish 8080:80 --publish 2222:22 --volumes-from gitlab_data genezys/gitlab:8.3.4
```

It might take a while before the docker container is responding to queries. You can follow the configuration process with `docker logs -f gitlab_app`.

You can then go to `http://localhost:8080/` (or `http://192.168.59.103:8080/` if you use boot2docker). You can login with username `root` and password `5iveL!fe`. Next time, you can just use `sudo docker start gitlab_app` and `sudo docker stop gitlab_app`.


Using Docker Compose
====================

You can download the `docker-compose.yml` file directly from the project repository. It will create a `data` container with the 3 volumes and an `app` container using the volumes of `data`.

To start the application using its default configuration, just run:

```bash
docker-compose up -d
```


How to configure GitLab
========================

This container uses the official Omnibus GitLab distribution, so all configuration is done in the unique configuration file `/etc/gitlab/gitlab.rb`.

To access GitLab configuration, you can start an interactive command line in a new container using the shared data volume container, you will be able to browse the 3 directories and use your favorite text editor:

```bash
docker run -ti -e TERM=linux --rm --volumes-from gitlab_data ubuntu
vi /etc/gitlab/gitlab.rb
```

**Note** that GitLab will reconfigure itself **at each container start.** You will need to restart the container to reconfigure your GitLab.

You can find all available options in [Omnibus GitLab documentation](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md#configuration).
