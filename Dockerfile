# Set the wanted Ubuntu & PHP versions
ARG UBUNTU_VERSION=22.04
ARG PHP_VERSION=8.1.14
ARG PHP_BASE_IMAGE=fpm


# Set the base image to Ubuntu
FROM ubuntu:${UBUNTU_VERSION}

# Install Nginx

# Add application repository URL to the default sources
RUN echo "deb http://archive.ubuntu.com/ubuntu/ raring main universe" >> /etc/apt/sources.list

# Update the repository & upgrade
RUN apt update && apt upgrade -y

# Install locale for Gettext
RUN apt -y install apt-utils
RUN apt -y install locales

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt install -y software-properties-common

# Install dependencies
RUN apt install -y && \
    bzip2 curl git less mysql-client sudo unzip zip \
    libbz2-dev libfontconfig1 libfontconfig1-dev \
    libfreetype6-dev libjpeg62-turbo-dev libpng12-dev libzip-dev

# Download and Install Nginx
RUN apt install -y nginx

# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/ph7builder.conf

# Copy a configuration file from the current directory
COPY ph7builder.conf /etc/nginx/

# Append "daemon off;" to the beginning of the configuration
RUN echo "daemon off;" >> /etc/nginx/ph7builder.conf

# Get PHP with its Docker image
FROM php:${PHP_VERSION}-${PHP_BASE_IMAGE}

RUN apt-get update && apt-get install -y libbz2-dev libzip-dev\
  && apt-get install -y wget git unzip libpq-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev

RUN docker-php-ext-install bz2 && \
    docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg && \
    docker-php-ext-install gd exif&& \
    docker-php-ext-install iconv && \
    docker-php-ext-install opcache && \
    docker-php-ext-install pdo && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install zip


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer
ENV PATH="~/.composer/vendor/bin:./vendor/bin:${PATH}"

