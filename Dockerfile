FROM jenkins/jenkins:latest
USER root
RUN apt-get update && apt-get install -y lsb-release net-tools tree
ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries


# Install Java.
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
 && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
 && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
 && rm -f /tmp/apache-maven.tar.gz \
 && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn


ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Define working directory.
WORKDIR /data

RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"



# Build Jenkins docker image
# docker build -t mrzvuz/myjenkins-blueocean:latest .

# Run Jenkins docker images
# docker run --name jenkins-blueocean --restart=on-failure --detach \
#   --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
#   --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
#   --publish 8080:8080 --publish 50000:50000 \
#   --volume jenkins-data:/var/jenkins_home \
#   --volume jenkins-docker-certs:/certs/client:ro \
#   mrzvuz/myjenkins-blueocean:latest

# Sign in to the container
# docker container exec -it jenkins-lts bash

# Push Jenkins Docker image to dockerhub repository
# docker push mrzvuz/myjenkins-blueocean:2.394