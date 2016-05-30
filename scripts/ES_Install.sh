!/bin/bash
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

# install elasticsearch
rpm --import https://packages.elasticsearch.org/GPG-KEY-elasticsearch
cat >> /etc/yum.repos.d/elasticsearch.repo << EOF
[elasticsearch-1.4]
name=Elasticsearch repository for 1.4.x packages
baseurl=http://packages.elasticsearch.org/elasticsearch/1.4/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOF

yum -y install elasticsearch
systemctl start elasticsearch.service
systemctl enable elasticsearch.service


cat >> /etc/elasticsearch/elasticsearch.yml << EOF
# Custom config parameters
script.disable_dynamic: true
EOF


sed -i 's/#network.host: 0.0.0.0/network.host: localhost/g' /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
sed -i 's/#discovery.zen.ping.multicast.enabled: false/discovery.zen.ping.multicast.enabled: false/g' /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
