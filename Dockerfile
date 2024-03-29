FROM centos:centos7
MAINTAINER Akram Ben Aissi <akram@free.fr> https://github.com/akram/manageiq 

RUN yum -y update sudo epel-release git libxml2-devel libxslt libxslt-devel; yum clean all

# Install various packages
RUN yum -y install nodejs net-tools git libxml2-devel libxslt libxslt-devel sudo tar which cmake

#Sudo requires a tty. fix that.
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers

# Install pgdg repo for getting new postgres RPMs
RUN rpm -ivh http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm

# Install Postgres Version 9.4
RUN yum install postgresql94-server postgresql94 postgresql94-contrib postgresql94-plperl postgresql94-devel -y --nogpgcheck

# Modified setup script to bypass systemctl variable read stuff
ADD ./postgresql94-setup /usr/pgsql-9.4/bin/postgresql94-setup

# Update data folder perms
RUN chown -R postgres.postgres /var/lib/pgsql

#Modify perms on setup script
RUN chmod +x /usr/pgsql-9.4/bin/postgresql94-setup

#Initialize data for pg engine
RUN sh /usr/pgsql-9.4/bin/postgresql94-setup initdb

#Access from all over --- NEVER DO THIS SHIT IN POST DEV ENVs !!!!!!!!!!!!!!!!!!! <--- READ THIS 
ADD ./postgresql.conf /var/lib/pgsql/9.4/data/postgresql.conf
ADD ./pg_hba.conf /var/lib/pgsql/9.4/data/pg_hba.conf

#Add start script for postgres
ADD ./start_postgres.sh /start_postgres.sh

RUN chmod +x /start_postgres.sh


RUN command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
RUN curl -sSL https://get.rvm.io | rvm_tar_command=tar bash -s stable

RUN /usr/local/rvm/bin/rvm install 2.2.2
env PATH /usr/local/rvm/rubies/ruby-2.2.2/bin/:/usr/pgsql-9.4/bin/:$PATH
RUN gem install bundler -v "~>1.3"
RUN git clone https://github.com/ManageIQ/manageiq
RUN source /etc/profile.d/rvm.sh

WORKDIR manageiq/vmdb
RUN bundle install --without qpid


#WORKDIR ..
#RUN vmdb/bin/rake build:shared_objects
#WORKDIR vmdb
#RUN bundle install --without qpid


WORKDIR /

EXPOSE 3000 4000
COPY launchManageIQ.sh /
RUN chmod +x /launchManageIQ.sh
COPY createDB.sh /
RUN chmod a+x /createDB.sh

CMD /launchManageIQ.sh

