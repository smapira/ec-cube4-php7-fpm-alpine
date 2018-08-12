FROM php:7.2-fpm-alpine

ENV WORKDIR "/var/www/"

RUN apk add --update --no-cache \
		autoconf \
		g++ \
		libtool \
		make \
		git \
		curl \
		php7-intl \
		sed

RUN set -ex; \
	\
	apk add --update --no-cache --virtual .build-deps \
		libjpeg-turbo-dev \
		libpng-dev \
		libevent-dev \
		icu-dev \
		postgresql-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mysqli opcache zip mbstring intl pgsql sockets pcntl; \
	\
	touch /usr/local/etc/php/bogus.ini \
	pear config-set php_ini /usr/local/etc/php/bogus.ini \
	pecl config-set php_ini /usr/local/etc/php/bogus.ini \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --virtual .ec-cube-phpexts-rundeps $runDeps;

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
		echo '[Date]'; \
		echo 'date.timezone = Asia/Tokyo'; \
	} > /usr/local/etc/php/conf.d/date.ini

RUN curl -sS https://getcomposer.org/installer | php
RUN php composer.phar create-project ec-cube/ec-cube app "4.0-beta"
RUN apk del .build-deps
EXPOSE 8000
ENTRYPOINT ["/usr/local/bin/php", "app/bin/console", "server:run", "*:8000"]
