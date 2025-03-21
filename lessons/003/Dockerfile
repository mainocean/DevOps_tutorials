FROM amazonlinux

RUN yum -y update
RUN yum -y install httpd
RUN yum -y install php
RUN ls -l /var/www/html/


COPY ./index.php /var/www/html/index.php



CMD ["/usr/sbin/httpd","-D","FOREGROUND"]

EXPOSE 80 