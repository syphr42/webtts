# This image is built from the guide on setting up a local
# Text-To-Speech (TTS) server found here:
# https://github.com/openhab/openhab/wiki/Use-local-TTS-with-squeezebox

FROM php:8-apache

# Working directory is set by parent image

# add non-free repository for dependencies
RUN sed -ie 's/^Components:\s\+main\s*$/Components: main contrib non-free/' /etc/apt/sources.list.d/debian.sources

# install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		curl \
		lame \
		libttspico-utils \
		libttspico-dev \
		libttspico-data \
		libttspico0 \
 && rm -r /var/lib/apt/lists/*

# install source
COPY src/ .

# install build dependencies and setup
RUN set -xe \
	&& buildDeps=" \
		git-core \
	" \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	\
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
	&& composer install \
	\
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps
