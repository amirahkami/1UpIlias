FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y software-properties-common curl wget && \
    add-apt-repository ppa:ondrej/php -y && \
    apt-get update -y

# Install Node.js 22.20.0 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs=22.20.0-1nodesource1

# Install Ghostscript from Ubuntu package manager
RUN apt-get install -y ghostscript

# Install base dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    zip \
    unzip \
    openjdk-21-jdk \
    maven \
    ffmpeg \
    git \
    && apt-get clean

# Install ImageMagick from Ubuntu package manager
RUN apt-get install -y \
    imagemagick \
    libmagickwand-dev

# Install Apache from Ubuntu package manager
RUN apt-get install -y \
    apache2 \
    apache2-dev

# Install PHP dependencies
RUN apt-get install -y \
    libapache2-mod-php8.3 \
    php8.3 \
    php8.3-gd \
    php8.3-xml \
    php8.3-imagick \
    php8.3-curl \
    php8.3-mysql \
    php8.3-xmlrpc \
    php8.3-soap \
    php8.3-ldap \
    php8.3-zip \
    php8.3-mbstring \
    php8.3-intl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Composer 2.8.x LTS
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=2.8.0

# Install ILIAS
RUN mkdir /var/www/ilias
RUN mkdir /var/www/files
RUN mkdir /var/www/logs
RUN mkdir /var/www/config
RUN mkdir /var/www/.npm
RUN chown -R www-data:www-data /var/www/ilias
RUN chown -R www-data:www-data /var/www/files
RUN chown -R www-data:www-data /var/www/logs
RUN chown -R www-data:www-data /var/www/config
RUN chown -R www-data:www-data /var/www/.npm

# Configure Apache modules (using Ubuntu package manager version)
RUN a2enmod rewrite
RUN a2enmod php8.3

# Configure Apache virtual host for ILIAS
RUN echo '<VirtualHost *:80>\n\
    ServerAdmin webmaster@example.com\n\
\n\
    DocumentRoot /var/www/ilias/public/\n\
    <Directory /var/www/ilias/>\n\
        Options +FollowSymLinks -Indexes\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
\n\
    # Possible values include: debug, info, notice, warn, error, crit,\n\
    # alert, emerg.\n\
    LogLevel warn\n\
\n\
    ErrorLog /var/log/apache2/error.log\n\
    CustomLog /var/log/apache2/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Enable the site
RUN a2ensite 000-default.conf

# Copy php.ini
COPY conf/php.ini /etc/php/8.3/apache2/php.ini

# Copy ilias.json
COPY conf/ilias.json.template /var/www/config/ilias.json

# Start Apache
CMD ["apache2ctl", "-D", "FOREGROUND"]

# Note: Apache will start automatically when container runs
