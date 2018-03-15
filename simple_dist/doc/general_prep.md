# General preparation

Here are some steps I execute on all splunk servers for preparation:

```
# Create splunk user and untar splunk
useradd -d /opt/splunk -m -r -s /bin/bash splunk
su - splunk
tar xzf /tmp/splunk-7.0.2-03bbabbd5c0f-Linux-x86_64.tgz
mv splunk/* .
rmdir splunk
```

I enabled splunk to start on boot by executing the following commands **as root**:
```
cd /opt/splunk/bin
./splunk enable boot-start -user splunk
```

```
