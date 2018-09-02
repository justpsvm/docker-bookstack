FROM php:7.1-apache-stretch

ENV BOOKSTACK=BookStack \
    BOOKSTACK_VERSION=0.23.2 \
    BOOKSTACK_HOME="/var/www/bookstack" 




COPY php.ini /usr/local/etc/php/php.ini
COPY bookstack.conf /etc/apache2/sites-enabled/bookstack.conf
COPY lib/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz /tmp/wkhtmltox.tar.xz


RUN echo "deb http://mirrors.aliyun.com/ubuntu/ artful main restricted universe multiverse \
            deb http://mirrors.aliyun.com/ubuntu/ artful-security main restricted universe multiverse \
            deb http://mirrors.aliyun.com/ubuntu/ artful-updates main restricted universe multiverse \
            deb http://mirrors.aliyun.com/ubuntu/ artful-backports main restricted universe multiverse\
            deb-src http://mirrors.aliyun.com/ubuntu/ artful main restricted universe multiverse \
            deb-src http://mirrors.aliyun.com/ubuntu/ artful-security main restricted universe multiverse \
            deb-src http://mirrors.aliyun.com/ubuntu/ artful-updates main restricted universe multiverse \
            deb-src http://mirrors.aliyun.com/ubuntu/ artful-backports main restricted universe multiverse\
            deb http://mirror.bjtu.edu.cn/ubuntu/ lucid main restricted  \
            deb-src http://mirror.bjtu.edu.cn/ubuntu/ lucid main restricted  \
            deb http://mirror.bjtu.edu.cn/ubuntu/ lucid-updates main restricted  \
            deb-src http://mirror.bjtu.edu.cn/ubuntu/ lucid-updates main restricted  \
            deb http://mirror.bjtu.edu.cn/ubuntu/ lucid universe  \
            deb-src http://mirror.bjtu.edu.cn/ubuntu/ lucid universe  \
            deb http://mirror.bjtu.edu.cn/ubuntu/ lucid-updates universe  \
            deb-src http://mirror.bjtu.edu.cn/ubuntu/ lucid-updates universe  \
            deb http://mirror.bjtu.edu.cn/ubuntu/ lucid multiverse  \
            deb-src http://mirror.bjtu.edu.cn/ubuntu/ lucid multiverse  \
            deb http://mirror.bjtu.edu.cn/ubuntu/ lucid-updates multiverse  \
            deb-src http://mirror.bjtu.edu.cn/ubuntu/ lucid-updates multiverse  \
            deb http://mirror.bjtu.edu.cn/ubuntu/ lucid-backports main restricted universe multiverse  \
            deb-src http://mirror.bjtu.edu.cn/ubuntu/ lucid-backports main restricted universe multiverse " >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --force-yes git zlib1g-dev libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev wget libldap2-dev libtidy-dev libfontconfig1 libxrender1 fontconfig fonts-droid-fallback fonts-noto-cjk \
   && docker-php-ext-install pdo pdo_mysql mbstring zip tidy \
   && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
   && docker-php-ext-install ldap \
   && docker-php-ext-configure gd --with-freetype-dir=usr/include/ --with-jpeg-dir=/usr/include/ \
   && docker-php-ext-install gd \
   && cd /var/www && curl -sS https://getcomposer.org/installer | php \
   && mv /var/www/composer.phar /usr/local/bin/composer \
   && cd /tmp && tar -xvf wkhtmltox.tar.xz && mv wkhtmltox/bin/wkhtmltoimage /usr/local/bin/wkhtmltoimage && mv wkhtmltox/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf \
   && wget https://github.com/ssddanbrown/BookStack/archive/v${BOOKSTACK_VERSION}.tar.gz -O ${BOOKSTACK}.tar.gz \
   && tar -xf ${BOOKSTACK}.tar.gz && mv BookStack-${BOOKSTACK_VERSION} ${BOOKSTACK_HOME} && rm ${BOOKSTACK}.tar.gz  \
   && cd $BOOKSTACK_HOME && composer install \
   && chown -R www-data:www-data $BOOKSTACK_HOME \
   && apt-get -y autoremove \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/* /var/tmp/* /etc/apache2/sites-enabled/000-*.conf

RUN a2enmod rewrite

COPY docker-entrypoint.sh /

WORKDIR $BOOKSTACK_HOME

EXPOSE 80

VOLUME ["$BOOKSTACK_HOME/public/uploads","$BOOKSTACK_HOME/public/storage"]

ENTRYPOINT ["/docker-entrypoint.sh"]  

ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.license="MIT" \
      org.label-schema.name="bookstack" \
      org.label-schema.vendor="solidnerd" \
      org.label-schema.url="https://github.com/solidnerd/docker-bookstack/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/solidnerd/docker-bookstack.git" \
      org.label-schema.vcs-type="Git"
