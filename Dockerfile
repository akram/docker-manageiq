FROM centos:6.4

MAINTAINER Mikael Gueck, gumi@iki.fi

RUN rpm -ih http://mirror.centos.org/centos/6/extras/x86_64/Packages/centos-release-SCL-6-5.el6.centos.x86_64.rpm

RUN rpm -ih http://dl.fedoraproject.org/pub/epel/6Server/x86_64/epel-release-6-8.noarch.rpm

RUN yum -y install \
  createrepo freeipmi fuse-libs httpd ipmitool libxml2-devel \
  libxslt-devel lshw memcached mod_ssl net-snmp net-snmp-libs \
  net-snmp-utils nfs-utils nodejs010-nodejs OpenIPMI \
  openslp-devel openssl-devel portmap \
  postgresql92-postgresql postgresql92-postgresql-devel postgresql92-postgresql-server \
  qpid-cpp-client-ssl ruby193-ruby ruby193-ruby-devel scl-utils-build \
  yum-utils zip zlib-devel \
  ruby193-rubygem-bundler ruby193-rubygem-net-http-persistent \
  ruby193-rubygem-thor ruby193-rubygem-thin ruby193-rubygem-daemons \
  ruby193-rubygem-eventmachine ruby193-rubygem-rack ruby193-rubygem-minitest

RUN yum -y install git libxml2-devel libxslt libxslt-devel make gcc gcc-c++
RUN yum -y install sudo memcached

RUN touch /etc/sysconfig/network
RUN /etc/rc.d/init.d/postgresql92-postgresql initdb
RUN echo "local all all trust" > /opt/rh/postgresql92/root/var/lib/pgsql/data/pg_hba.conf
RUN mkdir -p /opt/rh/postgresql92/root/etc/sysconfig/pgsql/
RUN echo "unset PG_OOM_ADJ" > /opt/rh/postgresql92/root/etc/sysconfig/pgsql/postgresql92-postgresql

RUN mkdir -p /var/www/
RUN git clone https://github.com/ManageIQ/manageiq.git /var/www/miq

RUN mkdir -p /var/www/miq/vmdb/log/apache

WORKDIR /var/www/miq/vmdb
RUN scl enable ruby193 postgresql92 nodejs010 "gem install bundler -v 1.3.5"
RUN scl enable ruby193 postgresql92 nodejs010 "bundle install"

VOLUME ["/opt/rh/postgresql92/root/var/lib/pgsql/data/"]
