# Docker Image: ghcr.io/sil-org/php8

Please submit a pull request or create an issue if you need another
module or package included or have other suggestions. The default
site was removed in order to load a custom vhost config, so when
extending this, use `ADD` or `COPY` to put a file into
`/etc/apache2/sites-enabled`.

# Getting Started

A full tutorial on using Docker is way beyond the scope of this
quick guide, but I'm happy to incorporate suggestions on how to
make this more thorough and easy for people to get started with.

1. [Install Docker](https://docs.docker.com/installation/)
2. Start the Docker host - on Linux just start the docker service.
   On Mac or Windows launch Docker Desktop, but be mindful that if
   creating a private repo, you will need a paid Docker Desktop license.
3. Download this Docker image by running: `docker pull ghcr.io/sil-org/php8`
4. Now you'll need to incorporate your application. The easiest way
   to do that is to create a simple Dockerfile for your project
   that is based on this image. See below for an example.
5. Build a Docker image for your application by running:
   `docker build -t="namespace/app-name"`
6. Finally, run your application as a Docker container by running:
   `docker run -d -P namespace/app-name`

You can check if your container is running by running
`docker ps` and see what port 80 got mapped to. Then you
should be able to access your application in your browser by
going to http://(DOCKER-IP-HERE):port

## Example Dockerfile for your application

```
FROM ghcr.io/sil-org/php8
LABEL maintainer="Your Name <your_email@domain.com>"

# Copy an Apache vhost file into sites-enabled. This should map
# the document root to whatever is right for your app
COPY vhost-config.conf /etc/apache2/sites-enabled/

RUN mkdir -p /data
VOLUME ["/data"]

# Copy your application source into the image
COPY application/ /data/

WORKDIR /data
EXPOSE 80
CMD ["apache2-foreground"]
```

## Example vhost file

```
<VirtualHost *:80>
  ServerName myapp.local
  DocumentRoot /data/frontend/web/
  #RewriteEngine On
  DirectoryIndex index.php

  <Directory /data/frontend/web/>
    Options FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>

  LogLevel info
  ErrorLog /var/log/apache2/myapp-error.log
  CustomLog /var/log/apache2/myapp-access.log combined

</VirtualHost>

<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
```

# Upgrade Process

The PHP version is tied to the Ubuntu version, which may delay and/or skip versions of PHP. The monthly build should pick up bug fixes, so no updates to this should be needed. For minor version upgrades, create a new branch, otherwise create a new repository.

1. In the Dockerfile, update the following:
   - Update ubuntu version in Dockerfile to newest version,
     creating that if necessary.
   - Update `REFRESHED_AT` and `MAINTAINER`, if needed
   - Update PHP version for config files at bottom of the file
2. For new branch, do the following:
   - Update default branch in Github to new branch

---
