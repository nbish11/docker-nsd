# syntax=docker/dockerfile:1-labs
FROM alpine:3.18 AS build

# Set build time arguments
ARG NSD_VERSION=4.7.0
ARG NSD_INSTALL_DIR=/usr/local/nsd
ARG NSD_STORAGE_DIR=/nsd
ARG NSD_HOME_DIR=/nsd

# experimental...
# @todo Disable the disk-database in settings/build
ARG LOWER_MEMORY_FOOTPRINT=false

# Set environment variables
ENV NSD_HOME_DIR=${NSD_HOME_DIR}

# Install necessary dependencies
RUN apk update && \
	apk add --no-cache \
	build-base \
	libevent-dev \
	libressl-dev \
	bison \
	flex \
	gnupg

# Download NSD source and its verification files into the working directory
WORKDIR /usr/local/src
RUN wget https://www.nlnetlabs.nl/downloads/nsd/nsd-${NSD_VERSION}.tar.gz \
	&& wget https://www.nlnetlabs.nl/downloads/nsd/nsd-${NSD_VERSION}.tar.gz.asc \
	&& wget https://www.nlnetlabs.nl/downloads/nsd/nsd-${NSD_VERSION}.tar.gz.sha256

# Verify the integrity and authenticity of the downloaded files
RUN gpg --recv-keys EDFAA3F2CA4E6EB05681AF8E9F6F1C2D7E045F8D \
	&& gpg --verify nsd-${NSD_VERSION}.tar.gz.asc nsd-${NSD_VERSION}.tar.gz

# Extract the NSD source code into the current directory
RUN tar -xzf nsd-${NSD_VERSION}.tar.gz -C . --strip-components=1 \
	&& chown -R root:root .

# configure and build NSD. if LOWER_MEMORY_FOOTPRINT has
# been set to true, then use the --disable-radix-tree and
# --enable-packed options
RUN if [ "$LOWER_MEMORY_FOOTPRINT" = true ]; then \
		./configure \
			--with-configdir=${NSD_HOME_DIR} \
			--sysconfdir=${NSD_HOME_DIR} \
			--with-libevent \
			--with-ssl \
			--with-pidfile=${NSD_HOME_DIR}/nsd.pid \
			--with-logfile=${NSD_HOME_DIR}/log.txt \
			--with-dbfile=${NSD_HOME_DIR}/nsd.db \
			--with-zonelistfile=${NSD_HOME_DIR}/zone.list \
			--with-xfrdir=${NSD_HOME_DIR} \
			--disable-radix-tree \
			--enable-packed; \
	else \
		./configure \
			--with-configdir=${NSD_HOME_DIR} \
			--sysconfdir=${NSD_HOME_DIR} \
			--with-libevent \
			--with-ssl \
			--with-pidfile=${NSD_HOME_DIR}/nsd.pid \
			--with-logfile=${NSD_HOME_DIR}/log.txt \
			--with-dbfile=${NSD_HOME_DIR}/nsd.db \
			--with-zonelistfile=${NSD_HOME_DIR}/zone.list \
			--with-xfrdir=${NSD_HOME_DIR}; \
	fi
RUN make && make install

# Move entrypoint to bin directory and make executable
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create a user and group for NSD to use
RUN addgroup -S nsd \
	&& adduser -S -G nsd nsd \
	&& chown -R nsd:nsd ${NSD_HOME_DIR}

# Clean up
# RUN rm -rf /usr/local/src

# Set the user and working directory
# USER nsd
WORKDIR ${NSD_HOME_DIR}

# Expose ports and set entrypoint
EXPOSE 53/tcp 53/udp
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "nsd", "-d" ]
VOLUME ${NSD_HOME_DIR}
