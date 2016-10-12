# This image is built from the guide on setting up a local
# Text-To-Speech (TTS) server found here:
# https://github.com/openhab/openhab/wiki/Use-local-TTS-with-squeezebox

FROM php:apache

# add non-free repository for dependencies
RUN sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list

# install setup & tts dependencies
RUN apt-get update && apt-get install -y \
		libttspico0 \
		libttspico-utils \
		libttspico-dev \
		libttspico-data \
		lame \
		curl \
		git \
	--no-install-recommends && rm -r /var/lib/apt/lists/*

# add php composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install source
COPY composer.json /var/www/html/
COPY tts.php /var/www/html/

# run composer to install php tts requirements
RUN composer install

CMD ["apache2-foreground"]
