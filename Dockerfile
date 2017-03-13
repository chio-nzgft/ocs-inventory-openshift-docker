FROM ubuntu:16.04
RUN apt-get update && apt -y dist-upgrade
RUN apt install -y git php-curl apache2-dev gcc perl-modules-5.22 libaio1\
     make apache2 php perl libapache2-mod-perl2 sudo \
         libapache2-mod-php libio-compress-perl libxml-simple-perl \
         libdbi-perl libdbd-mysql-perl libapache-dbi-perl libsoap-lite-perl \
         libnet-ip-perl php-mysql php-gd php7.0-dev php-mbstring php-soap php-xml \
         php-pclzip libarchive-zip-perl php7.0-zip
RUN PERL_MM_USE_DEFAULT=1 cpan -i CPAN
RUN perl -MCPAN -e 'install Apache2::SOAP'
RUN perl -MCPAN -e 'install XML::Entities'
RUN perl -MCPAN -e 'install Net::IP'
RUN perl -MCPAN -e 'install Apache::DBI'
RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
ADD z-ocsinventory-server.conf /etc/apache2/conf-available
ADD ocsinventory-reports.conf /etc/apache2/conf-available
RUN chown -R www-data:www-data /var/lib/ocsinventory-reports
RUN touch /var/log/ocsinventory-server
RUN chown -R  www-data:www-data /var/log/ocsinventory-server
RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/apache2
RUN /etc/init.d/apache2 stop
RUN chown -R www-data: /var/{log,run}/apache2/
RUN chown -R www-data: /usr/share/ocsinventory-reports/ocsreports
RUN sudo -u www-data apache2ctl start
RUN useradd -u 1001 user
RUN mkdir /home/user
ADD mysql.tar.gz /home/user
RUN chown -R user:user /home/user
EXPOSE 8080
USER 1001
RUN cd /home/user
RUN tar zxvf mysql.tar.gz
RUN rm -rf mysql.tar.gz
RUN cd mysql
RUN ./bin/mysqld_safe --defaults-file=/home/user/mysql/my.cnf &
RUN echo "#!/bin/bash" > /home/user/start.sh
RUN echo "while true; do" >> /home/user/start.sh
RUN echo "sleep 5" >> /home/user/start.sh
RUN echo "done" >> /home/user/start.sh
RUN chmod +x /home/user/start.sh
ENTRYPOINT /home/user/start.sh
