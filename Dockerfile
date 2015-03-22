FROM debian:wheezy

MAINTAINER Petri Sirkkala "sirpete@iki.fi"

RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ wheezy nginx" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.7.10-1~wheezy

RUN apt-get update && \
    apt-get install -y ca-certificates nginx=${NGINX_VERSION} fcgiwrap && \
    sed -i 's/^\(user .*\)$/user root;/' /etc/nginx/nginx.conf && \
    rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD spawn-fcgi -s /var/run/fcgiwrap.sock /usr/sbin/fcgiwrap && nginx -g daemon\ off\;
