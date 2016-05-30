/bin/bash
# for centos 7 installation choose "Basic Web Server" on install
# either add hostname to /etc/hosts or get external dns setup correctly
# restart apache if you cannot connect to the dashboard. all the other stuff needs to be up before apache


#set selinux to permissive
# not recommended for productions use
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config /etc/selinux/config

# install java and epel repos
yum install -y java-1.7.0-openjdk policycoreutils-python
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
sudo rpm -Uvh epel-release-7*.rpm

# kibana install
cd ~; curl -O https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz
tar xvf kibana-3.1.2.tar.gz
sed -i 's/elasticsearch: "http:\/\/"+window.location.hostname+":9200",/elasticsearch: "http:\/\/"+window.location.hostname+":80",/g' /root/kibana-3.1.2/config.js /root/kibana-3.1.2/config.js

mkdir -p /var/www/kibana3
cp -R ~/kibana-3.1.2/* /var/www/kibana3/

# make sure hostname is correct
cat > /etc/httpd/conf.d/kibana3.conf <<EOF
<VirtualHost $HOSTNAME:80>
    ServerName $HOSTNAME
    DocumentRoot /var/www/kibana3
    <Directory /var/www/kibana3>
        Allow from all
        Options -MultiViews
    </Directory>

 <Proxy http://localhost:9200>
    ProxySet connectiontimeout=5 timeout=90
  </Proxy>

  # Proxy for _aliases and .*/_search
  <LocationMatch "^/(_nodes|_aliases|.*/_aliases|_search|.*/_search|_mapping|.*/_mapping)$">
    ProxyPassMatch http://127.0.0.1:9200/$1
    ProxyPassReverse http://127.0.0.1:9200/$1
  </LocationMatch>

  # Proxy for kibana-int/{dashboard,temp} stuff (if you don't want auth on /, then you will want these to be protected)
  <LocationMatch "^/(kibana-int/dashboard/|kibana-int/temp)(.*)$">
    ProxyPassMatch http://127.0.0.1:9200/$1$2
    ProxyPassReverse http://127.0.0.1:9200/$1$2
  </LocationMatch>

<Location />
    AuthType Basic
    AuthBasicProvider file
    AuthName "Restricted"
    AuthUserFile /etc/httpd/conf.d/kibana-htpasswd
    Require valid-user
  </Location>
  </VirtualHost>
EOF

#set password for access to kibana
htpasswd -c /etc/httpd/conf.d/kibana-htpasswd user