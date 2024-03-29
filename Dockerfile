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

# we patch the ini file
# update the list from which to draw the projects from
# AND: update the File_extensions of the language to support java files as well:
RUN sed -i "s|FILE_projects_list =.*|FILE_projects_list=$HOME/input.lst|" "$SOURCERERCC_HOME/tokenizers/file-level/config.ini" && sed -i "s|File_extensions =.*|File_extensions = .cpp .hpp .c .h .java|" "$SOURCERERCC_HOME/tokenizers/file-level/config.ini"

COPY run_sourcerercc.sh sql/initialize.sql sql/query.sql /
USER sourcerercc-user

ENTRYPOINT [ "/bin/bash", "/run_sourcerercc.sh" ]