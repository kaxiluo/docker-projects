FROM linyiyong/php-fpm:7.4

COPY php7.4.ini /usr/local/etc/php/php.ini

RUN set -xe \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
       openssh-server \
       nginx \
    && docker-php-ext-install opcache

RUN mkdir -p /var/run/sshd \
  && sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config \
  && echo root:123456 | chpasswd

COPY ./magento.conf /etc/nginx/sites-enabled/magento.conf

ADD run.sh /run.sh

WORKDIR /workspace

CMD ["/run.sh"]

EXPOSE 22 80 9000
