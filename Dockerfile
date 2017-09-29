FROM ubuntu:16.04
# based on Vincent Robert <vincent.robert@genezys.net> initial Dockerfile
MAINTAINER Gauvain Pocentek <gauvain@pocentek.net>

# Install required packages
RUN apt-get update \
    && apt-get install -qy --no-install-recommends \
      openssh-server \
      ca-certificates \
      curl \
      tzdata \
    && curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash \
    && apt-get install -qy --no-install-recommends \
      gitlab-ce=10.0.1-ce.0

# Manage SSHD through runit
RUN mkdir -p /opt/gitlab/sv/sshd/supervise \
    && mkfifo /opt/gitlab/sv/sshd/supervise/ok \
    && printf "#!/bin/sh\nexec 2>&1\numask 077\nexec /usr/sbin/sshd -D" > /opt/gitlab/sv/sshd/run \
    && chmod a+x /opt/gitlab/sv/sshd/run \
    && ln -s /opt/gitlab/sv/sshd /opt/gitlab/service \
    && mkdir -p /var/run/sshd

# Default root password
RUN echo "gitlab_rails['initial_root_password'] = '5iveL!fe'" >> /etc/gitlab/gitlab.rb
RUN sed -i "s,^external_url.*,external_url 'http://gitlab.test'," /etc/gitlab/gitlab.rb

# Expose web & ssh
EXPOSE 80 22

# Default is to run runit & reconfigure
CMD sleep 3 && gitlab-ctl reconfigure & /opt/gitlab/embedded/bin/runsvdir-start
