#!/bin/bash
# Install the splunk universal forwarder

forwarder_tarball=/home/isaac/splunk/splunkforwarder-7.0.2-03bbabbd5c0f-Linux-x86_64.tgz
splunk_home=/opt/splunkforwarder

useradd -d ${splunk_home} -m -r -s /bin/bash splunk
cd ${splunk_home}
tar xzf ${forwarder_tarball}
mv splunkforwarder/* .
rmdir splunkforwarder
#chown -R splunk:splunk ${splunk_home}

cd ${splunk_home}/bin
./splunk enable boot-start -user splunk --accept-license

# create deploymentclients.conf:
conf_file=${splunk_home}/etc/system/local/deploymentclient.conf
cat >>${conf_file}<<EOF
[deployment-client]

[target-broker:deploymentServer]
targetUri= searchhead1:8089
EOF

# splunk home should be splunk owned
chown -R splunk:splunk ${splunk_home}
