# data node for mysql cluster
#
# version 0.0.1
FROM ubuntu:12.04
MAINTAINER Tim Schindler tim@catalyst-zero.com

# Define the environment.
ENV MYSQL_VERSION 7.3.5
ENV MYSQL_SHORT_VERSION 7.3
ENV PATH $PATH:/usr/local/mysql/bin

# Add mysql group and user.
RUN groupadd mysql
RUN useradd -g mysql mysql

# Install system requirements to install mysql from source.
RUN apt-get update
RUN apt-get install -y libaio1 libaio-dev libfile-basedir-perl

# Install mysql.
ADD http://cdn.mysql.com/Downloads/MySQL-Cluster-${MYSQL_SHORT_VERSION}/mysql-cluster-gpl-${MYSQL_VERSION}-linux-glibc2.5-x86_64.tar.gz /
RUN tar -xzvf mysql-cluster-gpl-${MYSQL_VERSION}-linux-glibc2.5-x86_64.tar.gz
RUN mv mysql-cluster-gpl-${MYSQL_VERSION}-linux-glibc2.5-x86_64 /usr/local/mysql
RUN cd /usr/local/mysql && ./scripts/mysql_install_db --user=mysql --datadir=/usr/local/mysql/data

# Cleanup
RUN rm -f mysql-cluster-gpl-${MYSQL_VERSION}-linux-glibc2.5-x86_64.tar.gz
RUN apt-get -f install && apt-get autoremove && apt-get -y autoclean && apt-get -y clean

# Apply user rights.
RUN chown -R root:mysql /usr/local/mysql
RUN chown -R mysql /usr/local/mysql/data

# Start mysql after machine boot.
RUN cp /usr/local/mysql/support-files/mysql.server /etc/init.d
RUN chmod +x /etc/init.d/mysql.server
RUN update-rc.d mysql.server defaults

ADD ./my.cnf /etc/my.cnf

RUN mkdir -p /var/lib/mysql-cluster
RUN echo "ndbd --initial" > /etc/init.d/ndbd
RUN chmod +x /etc/init.d/ndbd

# Expose the mysql port.
EXPOSE 3306
