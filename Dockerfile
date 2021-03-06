FROM ubuntu:14.04
MAINTAINER Hideyuki Takei <takehide22@gmail.com>

# apt-get
RUN apt-get update
RUN apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install curl vim git mercurial openssh-server sudo daemontools daemontools-run

# add user
RUN mkdir -p /var/run/sshd
RUN useradd -d /home/hide -m -s /bin/bash hide
RUN mkdir /home/hide/.ssh
RUN curl -L -k -o /home/hide/.ssh/authorized_keys -O https://dl.dropboxusercontent.com/u/180053/id_rsa.pub
RUN chown hide:hide -R /home/hide/.ssh
RUN chmod 600 /home/hide/.ssh/authorized_keys
RUN echo 'hide ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# ssh
RUN sed -ri 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# add ssh service on daemontools
RUN mkdir -p /etc/service/sshd
RUN mkdir -p /etc/service/sshd/log/main
ADD config/sshd_run /etc/service/sshd/run
RUN chmod +x /etc/service/sshd/run
ADD config/sshd_log_run /etc/service/sshd/log/run
RUN chmod +x /etc/service/sshd/log/run

# Install go
RUN curl -L -k -o /tmp/go.tar.gz -O http://golang.org/dl/go1.3.linux-amd64.tar.gz  
RUN tar -C /usr/local -xzf /tmp/go.tar.gz

# Initialize go env
RUN mkdir -p /usr/daily/go
ENV GOROOT /usr/local/go
ENV GOPATH /usr/daily/go
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

# Initialzie pluair dirs
RUN mkdir -p /usr/daily/app

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22
CMD ["/usr/bin/svscan", "/etc/service/"]

