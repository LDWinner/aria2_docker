FROM debian:8

# less priviledge user, the id should map the user the downloaded files belongs to
RUN groupadd -r dummy && useradd -r -g dummy dummy -u 1000


# webui + aria2
RUN apt-get update \
	&& apt-get install -y aria2 curl unzip \
	&& rm -rf /var/lib/apt/lists/*


# gosu install latest
RUN GITHUB_REPO="https://github.com/tianon/gosu" \
  && LATEST=`curl -s  $GITHUB_REPO"/releases/latest" | grep -Eo "[0-9].[0-9]*"` \
  && curl -L $GITHUB_REPO"/releases/download/"$LATEST"/gosu-amd64" > /usr/local/bin/gosu \
  && chmod +x /usr/local/bin/gosu

# goreman supervisor install latest
RUN GITHUB_REPO="https://github.com/mattn/goreman" \
  && LATEST=`curl -s  $GITHUB_REPO"/releases/latest" | grep -Eo "v[0-9]*.[0-9]*.[0-9]*"` \
  && curl -L $GITHUB_REPO"/releases/download/"$LATEST"/goreman_linux_amd64.zip" > goreman.zip \
  && unzip goreman.zip && mv /goreman /usr/local/bin/goreman && rm -R goreman*

# goreman setup
RUN echo "aria2: gosu dummy /usr/bin/aria2c --conf-path='/config/aria2.conf'" > Procfile

COPY root/ /

RUN chmod +x init

# aria2 downloads directory
VOLUME /download /config


# webui static content web server, map wherever is convenient
EXPOSE 6800/tcp

#CMD ["start"]
#ENTRYPOINT ["/usr/local/bin/goreman"]

ENTRYPOINT ["/init"]
