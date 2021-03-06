FROM ubuntu:latest

RUN apt-key update
RUN apt-get update 

RUN apt-get install -qy python-software-properties
RUN apt-get install -qy python-software-properties
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update

RUN apt-get install -qy nginx
RUN apt-get install -qy vim
RUN apt-get install -qy supervisor
RUN apt-get install -qy git
RUN apt-get install -qy dpkg-dev
RUN apt-get install -qy php5
RUN apt-get install -qy php5-mysql
RUN apt-get install -qy php5-gd
RUN apt-get install -qy php5-dev
RUN apt-get install -qy php5-curl
RUN apt-get install -qy php-apc
RUN apt-get install -qy php5-cli
RUN apt-get install -qy php5-json
RUN apt-get install -qy php5-fpm
RUN apt-get install -qy mysql-client

RUN git clone git://github.com/facebook/libphutil.git /var/www/libphutil
RUN git clone git://github.com/facebook/arcanist.git /var/www/arcanist
RUN git clone git://github.com/facebook/phabricator.git /var/www/phabricator

RUN mkdir -p /var/run/nginx
RUN mkdir -p /var/run/php5-fpm
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/nginx/temp
RUN mkdir -p /var/nginx/cache/phab
RUN mkdir -p /var/log/nginx
RUN mkdir -p /var/repo

RUN chown www-data:www-data /var/repo

RUN touch /var/log/nginx/access.log
RUN touch /var/log/nginx/error.log

RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php5/fpm/php-fpm.conf
RUN sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/g' /etc/php5/fpm/pool.d/www.conf
RUN sed -i 's/pm = dynamic/pm = ondemand/' /etc/php5/fpm/pool.d/www.conf
RUN echo "apc.stat = 0" >> /etc/php5/fpm/php.ini

RUN rm /etc/nginx/nginx.conf /etc/nginx/sites-enabled/* /etc/nginx/sites-available/*

ADD ./ssl /ssl
ADD ./setup /setup
ADD ./conf /conf
ADD ./run /run

RUN /bin/bash /setup/setup.sh

ADD ./conf/nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./conf/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./conf/phabricator/local.json /var/www/phabricator/conf/local/local.json

EXPOSE 80/tcp 443/tcp

CMD ["/bin/bash", "/run/start.sh"]
