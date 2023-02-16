## updated Dockerfile from this excellent repo/blog
## https://github.com/joshuarobinson/trino-on-k8s/tree/master/hive_metastore
FROM openjdk:8-slim

ARG HADOOP_VERSION=3.3.4

RUN apt-get update && apt-get install -y curl --no-install-recommends \
        && rm -rf /var/lib/apt/lists/*

# Download and extract the Hadoop binary package.
RUN curl https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
        | tar xvz -C /opt/  \
        && ln -s /opt/hadoop-$HADOOP_VERSION /opt/hadoop \
        && rm -r /opt/hadoop/share/doc

# Add S3a jars to the classpath using this hack.
RUN ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/aws-java-sdk* /opt/hadoop/share/hadoop/common/lib/

# Set necessary environment variables.
ENV HADOOP_HOME="/opt/hadoop"
ENV PATH="/opt/spark/bin:/opt/hadoop/bin:${PATH}"

# Download and install the standalone metastore binary.
RUN curl https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/3.1.3/hive-standalone-metastore-3.1.3-bin.tar.gz \
        | tar xvz -C /opt/ \
        && ln -s /opt/apache-hive-metastore-3.1.3-bin /opt/hive-metastore

# Download and install the mysql connector.
RUN curl -L  https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.0.32.tar.gz \
        | tar xvz -C /opt/ \
        && ln -s /opt/mysql-connector-java-8.0.32/mysql-connector-java-8.0.32.jar /opt/hadoop/share/hadoop/common/lib/ \
        && ln -s /opt/mysql-connector-java-8.0.32/mysql-connector-java-8.0.32.jar /opt/hive-metastore/lib/
~
