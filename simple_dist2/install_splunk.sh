#!/bin/bash
# Install splunk - suitable for indexers and search heads

splunk_tarball=/home/isaac/splunk/splunk-7.0.2-03bbabbd5c0f-Linux-x86_64.tgz
splunk_home=/opt/splunk

cd ${splunk_home}
tar xzf ${splunk_tarball}
mv splunk/* .
rmdir splunk
chown -R splunk:splunk ${splunk_home}

cd ${splunk_home}/bin
./splunk enable boot-start -user splunk --accept-license

# open firewall ports
# web interface
#firewall-cmd --add-port=8000/tcp
#firewall-cmd --add-port=8000/tcp --permanent
# splunkd, needed for forwarder management
firewall-cmd --add-port=8089/tcp
firewall-cmd --add-port=8089/tcp --permanent

