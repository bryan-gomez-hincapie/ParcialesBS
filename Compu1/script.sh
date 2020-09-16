#!/bin/bash

lxc init ubuntu:18.04 prueba
lxc init ubuntu:18.04 haproxy
lxc init ubuntu:18.04 web1A --target ubuntu2A
lxc init ubuntu:18.04 web2A --target ubuntu3A
lxc init ubuntu:18.04 web1BA --target ubuntu2A
lxc init ubuntu:18.04 web2BA --target ubuntu3A

lxc start haproxy web1A web1BA web2A web2BA

sleep 5

#APROVICIONAMIENTO DE HAPROXY EN EL CONTENEDOR HAPROXY
lxc exec haproxy -- apt install haproxy -y
lxc exec haproxy -- systemctl enable haproxy
lxc exec haproxy -- systemctl start haproxy
lxc file push /vagrant/haproxy/haproxy.cfg haproxy/etc/haproxy/haproxy.cfg
lxc exec haproxy -- mkdir -p /etc/haproxy/errorfiles
lxc file push /vagrant/Sorry/sorry.http haproxy/etc/haproxy/errorfiles/sorry.http
lxc exec haproxy -- systemctl restart haproxy

#APROVISIONAMIENTO DE APACHE EN EL CONTAINER WEB1A
lxc exec web1A -- apt install apache2 -y
lxc exec web1A -- systemctl enable apache2
lxc file push /vagrant/Web1/index1.html web1A/var/www/html/index.html
lxc exec web1A -- systemctl start apache2

#APROVISIONAMIENTO DE APACHE EN EL CONTAINER WEB1BA
lxc exec web1BA -- apt install apache2 -y
lxc exec web1BA -- systemctl enable apache2
lxc file push /vagrant/Web1/index2.html web1BA/var/www/html/index.html
lxc exec web1BA -- systemctl start apache2

#APROVISIONAMIENTO DE APACHE EN EL CONTAINER WEB2A
lxc exec web2A -- apt install apache2 -y
lxc exec web2A -- systemctl enable apache2
lxc file push /vagrant/Web2/index1.html web2A/var/www/html/index.html
lxc exec web2A -- systemctl start apache2

#APROVISIONAMIENTO DE APACHE EN EL CONTAINER WEB2BA
lxc exec web2BA -- apt install apache2 -y
lxc exec web2BA -- systemctl enable apache2
lxc file push /vagrant/Web2/index2.html web2BA/var/www/html/index.html
lxc exec web2BA -- systemctl start apache2

#REENVIO DE PUERTOS
lxc config device add haproxy parcial proxy listen=tcp:0.0.0.0:1328 connect=tcp:127.0.0.1:80
lxc restart haproxy

#lxc exec haproxy -- vim /etc/haproxy/haproxy.cfg