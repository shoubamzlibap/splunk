# The data mill
Here I describe how I generated some sample logs, and also how I onboarded that data into splunk.

## Generating data
There are various data generators, most notably [Eventgen](https://github.com/splunk/eventgen). However its not really designed as a standalone generator, its seems to be tightly coupled with
splunk. 
However the point of this exercise is to get data into splunk, so for the moment I am not looking at Eventgen.

Then there is [gogen](https://github.com/coccyx/gogen), which is a successor of Eventgen, and designed for standalone operations. I am trying this one out.

And then there is [Slogger](https://sourceforge.net/projects/syslog-slogger/). And probably a lot more.


## Generating data with gogen - simple weg log
I downloaded gogen from the above link, some sample data, and generated some logs:

```
mkdir gogens
./gogen pull coccyx/weblog gogens
./gogen -c gogens/weblog.yml -o file -f log/access.log  gen -c 7 -i 10 --ei 10
```
This will create a file `log/access.log`, with access logs, with time stamps 10 seconds appart, 7 entries per time stamp, for 10 intervalls.

If you just want to create a log on an ongoing basis, this will do the trick:

```
./gogen -c gogens/weblog.yml -o file -f log/access.log gen -r
```

### Logs from a different user
To mimic real scenarios, I created logs with a different user:
```
useradd -d /opt/datagen -m -r -s /bin/bash datagen
su - datagen
mkdir log
```

Then I generate a sample weblog with the following command:

```
./gogen -c gogens/weblog.yml -o file -f log/access.log gen -r -c 1 -i 10
```

In order to make the logs accessible to splunk, I will use acls. As root, I executed
```
# make all current files readable by splunk:
setfacl -R -m u:splunk:rx /opt/datagen
# set a default acl on the log directory, so that also newly created files will be readable:
setfacl -d -m u:splunk:rx /opt/datagen/log
```

# Forwarding the data to the indexers
Now that I have a datasource, I want to ingest that data into splunk. If the data is going into a seperate index or not might be up for discussion. However the whole point of this is to
excercise, so I am going to put this into a new index.

## Install the splunk forwarder
Download the universal forwarder from splunk, put it on your system, and execute the following commands:
```
useradd -d /opt/splunkforwarder -m -r -s /bin/bash splunk
cd /opt/splunkforwarder
tar xzf /tmp/splunkforwarder-7.0.2-03bbabbd5c0f-Linux-x86_64.tgz 
mv splunkforwarder/* .
chown -R splunk:splunk /opt/splunkforwarder
```

Enable boot start with the following command:
```
cd /opt/splunkforwarder/bin
./splunk enable boot-start -user splunk
```

## Scripted forwarder installation
To be added.

## Connect the forwarder to the indexers
Create a `outputs.conf` similar to the one on the searhead:
```
[tcpout]
defaultGroup = my_search_peers 
forwardedindex.filter.disable = true  
indexAndForward = false 
 
[tcpout:my_search_peers]
server=10.23.23.5:9997,10.23.23.6:9997

```

Restart your splunk forwarder.

## Monitor a log file
In your `etc/system/local/inputs.conf`, add the following stanza to monitor the access.log we created earlier:

```
[monitor:///opt/datagen/log/access.log]
disabled = 0
index=weblogs
sourcetype = access_combined
```
