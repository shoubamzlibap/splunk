# General preparation

Here are some steps I execute on all splunk servers for preparation:

```
useradd -d /opt/splunk -m -r -s /bin/bash splunk
su - splunk
tar xzf /tmp/splunk-7.0.2-03bbabbd5c0f-Linux-x86_64.tgz
mv splunk/* .
rmdir splunk
```
