FROM jenkins/jenkins:2.73.3

LABEL maintainer="Dean Godfree <dean.j.godfree@accenture.com>"

ENV GERRIT_HOST_NAME gerrit
ENV GERRIT_PORT 8080
ENV GERRIT_SSH_PORT 29418
ENV GERRIT_PROFILE="ADOP Gerrit" GERRIT_JENKINS_USERNAME="" GERRIT_JENKINS_PASSWORD=""

# Copy in configuration files
COPY resources/plugins-latest.txt /usr/share/jenkins/ref/
COPY resources/init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/
COPY resources/scripts/ /usr/share/jenkins/ref/adop_scripts/
COPY resources/jobs/ /usr/share/jenkins/ref/jobs/
COPY resources/scriptler/ /usr/share/jenkins/ref/scriptler/scripts/
COPY resources/views/ /usr/share/jenkins/ref/init.groovy.d/
COPY resources/m2/ /usr/share/jenkins/ref/.m2
COPY resources/entrypoint.sh /entrypoint.sh
#COPY resources/scriptApproval.xml /usr/share/jenkins/ref/

# Reprotect
USER root
RUN apt-get update && apt-get install -y dos2unix
RUN chmod +x -R /usr/share/jenkins/ref/adop_scripts/ && chmod +x /entrypoint.sh
# USER jenkins

# 2.73.1 changes compliance
## SSHD Module 2.0 has been integrated towards the Jenkins 2.69 release
RUN echo "    KexAlgorithms diffie-hellman-group1-sha1,diffie-hellman-group-exchange-sha256" >> /etc/ssh/ssh_config

# Environment variables
ENV ADOP_LDAP_ENABLED=true \
    ADOP_ACL_ENABLED=true \
    ADOP_SONAR_ENABLED=false \
    ADOP_ANT_ENABLED=true \
    ADOP_MAVEN_ENABLED=true \
    ADOP_NODEJS_ENABLED=false \
    ADOP_GERRIT_ENABLED=false
ENV JAVA_OPTS="-Dpermissive-script-security.enabled=true"
ENV LDAP_GROUP_NAME_ADMIN=""
ENV JENKINS_OPTS="--prefix=/jenkins -Djenkins.install.runSetupWizard=false"
ENV PLUGGABLE_SCM_PROVIDER_PROPERTIES_PATH="/var/jenkins_home/userContent/datastore/pluggable/scm"
ENV PLUGGABLE_SCM_PROVIDER_PATH="/var/jenkins_home/userContent/job_dsl_additional_classpath/"

RUN dos2unix /usr/share/jenkins/ref/plugins-latest.txt && apt-get --purge remove -y dos2unix && rm -rf /var/lib/apt/lists/*
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins-latest.txt

ENTRYPOINT ["/entrypoint.sh"]
