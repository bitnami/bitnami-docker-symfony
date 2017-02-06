FROM gcr.io/stacksmith-images/minideb-buildpack:jessie-r8

MAINTAINER Bitnami <containers@bitnami.com>

RUN echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list
RUN apt-get update && apt-get install -t jessie-backports -y openjdk-8-jdk-headless
RUN install_packages git subversion openssh-server rsync
RUN mkdir /var/run/sshd && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV BITNAMI_APP_NAME=che-symfony \
    BITNAMI_IMAGE_VERSION=3.1.3-r10 \
    PATH=/opt/bitnami/symfony:/opt/bitnami/php/bin:/opt/bitnami/mysql/bin/:$PATH

# Install Symfony dependencies
RUN bitnami-pkg install php-7.0.15-4 --checksum 855e77fc7b87d1b263b08fdc96518c6fc301531923974917335f1cb8539d2a68
RUN bitnami-pkg install mysql-client-10.1.21-0 --checksum 8e868a3e46bfa59f3fb4e1aae22fd9a95fd656c020614a64706106ba2eba224e
RUN bitnami-pkg unpack mariadb-10.1.21-0 --checksum ecf191e709c35881b69ff5aea22da984b6d05d4b751a0d5a72fa74bb02b71eea

# Install Symfony module
RUN bitnami-pkg install symfony-3.2.2-0 --checksum c67ef324d21969bd537f8012ddcb196ce293a6a07d680d34ad6b8402814fbdd7 -- --applicationDirectory /projects

EXPOSE 8000

# Set up Codenvy integration
LABEL che:server:8000:ref=symfony che:server:8000:protocol=http

USER bitnami
WORKDIR /projects

ENV TERM=xterm

CMD sudo /usr/sbin/sshd -D && sudo HOME=/root /opt/bitnami/nami/bin/nami start --foreground mariadb

