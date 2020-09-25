FROM php:7.4-cli

LABEL maintainer="Mateusz Gostanski <mg@grixu.dev>"

ARG user_uid=1001
ARG group_gid=1001

RUN apt-get update

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    libcurl3-dev \
    zip \
    libgmp-dev \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    procps \
    iputils-ping \
    nano

RUN apt-get update && apt-get install -y \
    libmcrypt-dev \
    zlib1g-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    graphviz

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl curl bcmath
RUN docker-php-ext-install gd gmp

RUN apt-get update && \
    pecl channel-update pecl.php.net && \
    pecl install redis && \
    docker-php-ext-enable redis && \
    docker-php-source delete

RUN apt-get install -y libmagickwand-dev
# RUN pecl install imagick && docker-php-ext-enable imagick

RUN apt-get update && \
    pecl channel-update pecl.php.net && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    docker-php-source delete

# Human Language and Character Encoding Support
RUN apt-get install -y zlib1g-dev libicu-dev g++
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY php.ini /usr/local/etc/php/php.ini

RUN mkdir /home/nginx
RUN addgroup --system --gid $group_gid nginx
RUN useradd --uid $user_uid -g $group_gid --home-dir /home/nginx nginx

# ---- Unique for supervisor only ---->

# Prepare log files
RUN touch /var/log/cron.log
RUN touch /var/log/horizon.log
RUN touch /var/log/supervisord.log

# Supervisor
RUN apt-get install -y supervisor

# Add supervisor configuration
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Crontab
RUN apt-get install -y cron
COPY cron.d/schedule /etc/cron.d
RUN chmod -R 644 /etc/cron.d
RUN crontab /etc/cron.d/schedule

# Clean up
RUN apt-get clean
RUN apt-get -y autoremove
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set up default directory
WORKDIR /etc/supervisor/conf.d/

# Run after container is up
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
