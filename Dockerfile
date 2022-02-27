FROM openjdk:18-alpine3.15

ENV HOME=/home/sourcerercc-user
# github naming
ENV SOURCERERCC_HOME="$HOME/SourcererCC-master"

RUN addgroup --gid 1000 sourcerercc-user && adduser --uid 1000 --ingroup sourcerercc-user --home "$HOME" --disabled-password sourcerercc-user

RUN apk add --update --no-cache bash wget zip unzip python3 python2 file mysql-client
RUN python3 -m ensurepip
RUN python2 -m ensurepip
RUN pip2 install mysql-connector

# ANT
ENV APACHE_ANT_VERSION=1.10.12
RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-$APACHE_ANT_VERSION-bin.tar.gz --directory-prefix /opt/ant/
RUN tar -xvzf /opt/ant/apache-ant-$APACHE_ANT_VERSION-bin.tar.gz --directory /opt/ant/
RUN rm -f /opt/ant/apache-ant-$APACHE_ANT_VERSION-bin.tar.gz
ENV ANT_HOME=/opt/ant/apache-ant-$APACHE_ANT_VERSION
ENV PATH="${PATH}:${ANT_HOME}/bin"

WORKDIR "$HOME"
# retrieve the git repo; TODO: test with tag v1.0
RUN wget https://github.com/Mondego/SourcererCC/archive/refs/heads/master.zip --directory-prefix "$HOME"
RUN unzip master.zip
RUN rm -rf master.zip

RUN chown -R -c sourcerercc-user "$SOURCERERCC_HOME"

COPY run_sourcerercc.sh initialize.sql query.sql /
COPY projects.txt "$HOME/input.lst"
RUN chown -c sourcerercc-user "$HOME/input.lst"
USER sourcerercc-user

ENTRYPOINT [ "/bin/bash", "/run_sourcerercc.sh" ]