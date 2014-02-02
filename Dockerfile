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

RUN mkdir -p /var/run/nginx
RUN mkdir -p /var/run/php5-fpm
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/nginx/cache/phab

RUN git clone git://github.com/facebook/libphutil.git /var/www/libphutil
RUN git clone git://github.com/facebook/arcanist.git /var/www/arcanist
RUN git clone git://github.com/facebook/phabricator.git /var/www/phabricator

RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php5/fpm/php-fpm.conf
RUN sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/g' /etc/php5/fpm/pool.d/www.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN echo "apc.stat = 0" >> /etc/php5/fpm/php.ini


ADD ./ssl /ssl
ADD ./setup /setup
ADD ./conf /conf


ADD ./conf/nginx/default /etc/nginx/sites-available/default
ADD ./conf/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN /bin/bash /setup/phabricator.sh

RUN cat /conf/phabricator/default-namespace.private | xargs -I % /var/www/phabricator/bin/config set storage.default-namespace %
RUN cat /conf/phabricator/mysql_host.private | xargs -I % /var/www/phabricator/bin/config set mysql.host %
RUN cat /conf/phabricator/mysql_port.private | xargs -I % /var/www/phabricator/bin/config set mysql.port %
RUN cat /conf/phabricator/mysql_user.private | xargs -I % /var/www/phabricator/bin/config set mysql.user %
RUN cat /conf/phabricator/mysql_pass.private | xargs -I % /var/www/phabricator/bin/config set mysql.pass %

RUN /var/www/phabricator/bin/storage upgrade --force
EXPOSE 80/tcp 443/tcp

CMD ["/usr/bin/supervisord", "--nodaemon"]
