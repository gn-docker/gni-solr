FROM debian:wheezy
MAINTAINER Dmitry Mozzherin
ENV LAST_FULL_REBUILD 2016-01-07
RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get upgrade -y && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
    apt-get update && \
    apt-get -y install locales git && \
    sed -i.bak -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    update-locale LC_ALL= "en_US.UTF-8" && \
    export LANGUAGE=en_US:en && \
    export LANG=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get -y install oracle-java7-installer && \
    update-alternatives --display java && \
    apt-get -y install oracle-java7-set-default && \
    rm -fr /var/cache/oracle-jdk7-installer && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
ENV LANGUAGE   en_US:en
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle
ENV SOLR_VERSION 3.5.0
ENV SOLR apache-solr-$SOLR_VERSION
ENV SOLR_DOWNLOAD http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/$SOLR.tgz

RUN \
  apt-get update && \
  apt-get -y install lsof curl procps && \
  mkdir -p /opt/solr && \
  wget -nv --output-document=/opt/$SOLR.tgz $SOLR_DOWNLOAD && \
  tar -C /opt --extract --file /opt/$SOLR.tgz && \
  rm /opt/$SOLR.tgz && \
  mv /opt/$SOLR/* /opt/solr && \
  git clone https://github.com/GlobalNamesArchitecture/gni.git && \
  cd gni && git checkout docker && cd .. && \
  # mkdir gni/solr/example && \
  # mkdir gni/solr/example/data && \
  mv gni/solr/multicore /opt/solr/gni && \
  apt-get -y purge git && \
  apt-get -y autoremove && \
  rm -rf gni

VOLUME /opt/solr

EXPOSE 8983
CMD ["/bin/bash", "-c", "cd /opt/solr/example && java -Xms3800m -Xmx3800m -Dsolr.solr.home=/opt/solr/gni -jar start.jar > /var/log/solr.log 2>&1"] 
