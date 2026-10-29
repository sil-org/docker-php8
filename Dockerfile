FROM ubuntu:24.04
LABEL maintainer="gtis_itse_support@sil.org"

ENV REFRESHED_AT 2024-09-11
ENV HTTPD_PREFIX /etc/apache2
ENV DEBIAN_FRONTEND noninteractive

# Set up default locale environment variables
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"

# Install OS packages
# Specific php versions are not required as ubuntu is feature complete
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    libapache2-mod-php \
    locales \
    nano \
    php \
    php-cli \
    php-curl \
    php-intl \
    php-ldap \
    php-mbstring \
    php-mcrypt \
    php-mysql \
    php-sqlite3 \
    php-gmp \
    php-xml \
    php-zip \
    s3cmd \
    unzip \
    zip \
    # Force security upgrades
    openssl \
    libssl3 \
    apache2 \
    && phpenmod mcrypt \
    # Update the /etc/default/locale file
    # removing locales causes issues
    && locale-gen en_US.UTF-8 \
    && update-locale LANG="$LANG" \
    && update-locale LANGUAGE="$LANGUAGE" \
    && update-locale LC_ALL="$LC_ALL" \
    # Clean up to reduce docker image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Install s3-expand
ADD https://raw.githubusercontent.com/sil-org/s3-expand/master/s3-expand /usr/local/bin/s3-expand
RUN chmod a+rx /usr/local/bin/s3-expand

# Remove default site, configs, and mods not needed
WORKDIR $HTTPD_PREFIX
RUN a2dissite 000-default
RUN a2disconf serve-cgi-bin
### WARNING: The following essential module will be disabled.
### This might result in unexpected behavior and should NOT be done
### unless you know exactly what you are doing!
RUN a2dismod autoindex -f

# Enable additional configs and mods
RUN a2enmod expires headers rewrite

# Remove default ssl key
RUN rm /etc/ssl/private/*

# Copy in any additional PHP ini files to the folders where they will be found.
COPY conf/*.ini /etc/php/8.3/apache2/conf.d/
COPY conf/*.ini /etc/php/8.3/cli/conf.d/

COPY vhost.conf /etc/apache2/sites-enabled/

RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

ADD --checksum=sha256:e60eee0f61ccb2643fb93201f5299e7a07e84e29c7ffa4c8ba51ab71c9115873 \
  https://github.com/sil-org/config-shim/releases/download/v1.3.4/config-shim.gz config-shim.gz

RUN <<'EOF' bash -e
gzip -d config-shim.gz
chmod 755 config-shim
mv config-shim /usr/local/bin
EOF

# Install apache2-foreground
COPY --chmod=755 apache2-foreground /usr/local/bin/

EXPOSE 80

# By default, simply start apache.
# Exec form; shell form would keep `sh -c` as PID 1, which ignores the stop signal.
CMD ["apache2-foreground"]
