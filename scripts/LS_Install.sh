#install logstash
cat > /etc/yum.repos.d/logstash.repo <<EOF
[logstash-1.4]
name=logstash repository for 1.4.x packages
baseurl=http://packages.elasticsearch.org/logstash/1.4/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOF

yum -y install logstash logstash-contrib

#create key for if you use logstash forwarded to this server
cd /etc/pki/tls; sudo openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt


cat > /etc/logstash/conf.d/01-lumberjack-input.conf <<EOF
input {
  syslog {
    port => 5514
    }
}
EOF

cat > /etc/logstash/conf.d/10-syslog.conf <<EOF
filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
      add_field => [ "received_at", "%{@timestamp}" ]
      add_field => [ "received_from", "%{host}" ]
    }
    syslog_pri { }
    date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}
EOF

cat > /etc/logstash/conf.d/30-lumberjack-output.conf <<EOF
output {
  elasticsearch { host => localhost }
  stdout { codec => rubydebug }
}
EOF

# port forward syslogs 514 to 5514 in firewall gui, turn on http
# might not need this firewall-cmd --zone=public --add-masquerade
firewall-cmd --zone=public --add-forward-port=port=514:proto=udp:toport=5514 --permanent
firewall-cmd --zone=public --add-port=514/udp --permanent
firewall-cmd --reload



yum install -y python-pip
pip install elasticsearch-curator


# need to put in crontab----- delete files older than "90" days for maintenance
curator delete indices --time-unit days --older-than 90 --timestring %Y.%m.%d

systemctl start logstash.service
systemctl enable logstash.service
systemctl restart httpd.service