# Indexer Installation

I have installed the indexers with the same minimal script, [install_splunk.sh](./install_splunk.sh).

Again, I have set the servername in `/opt/splunk/etc/system/local/server.conf`:
```
[general]
serverName = myIndexer2
```

## Minimum Free Diskspace for a small test environment
This is a setting that will probably not bug you in production, but my test boxes are rather small, with a root fs of just 8GB. Soon your splunk indexers will complain with a message like

```
Search peer idx1 has the following message: Disk Monitor: The index processor has paused data flow. Current free disk space on partition '/' has fallen to 4426MB, below the minimum of 5000MB. Data writes to index path '/opt/splunk/var/lib/splunk/audit/db'cannot safely proceed. Increase free disk space on partition '/' by removing or relocating data.
```

My "solution" is to change the `minFreeSpace` value in `etc/system/local/server.conf` to something below 5GB. I currently do not know, but there is probablyl a reason for this limit, so bevor 
you do this on production I highly recommend you really know what you do. After all, what is 5GB in production? For my laptop's ssd its a bunch, so I am setting this:
```
[diskUsage]
minFreeSpace = 1000
```

## Disable Web
Usually the indexers don't need a webinterface, so its good practise to disable it. On both of the indexers, create a file called `web.conf` with the following content:
```
mkdir -p etc/apps/ia_web/default
cat >>etc/apps/ia_web/default/web.conf<<EOF
[settings]
startwebserver = 0
EOF
```



## Create indexes
Create some indexes by creating an `indexes.conf` file, preferably inside an app:
```
mkdir -p etc/apps/ia_indexes/default
cat >>etc/apps/ia_indexes/default/indexes.conf<<EOF
[main]
disabled = 0
homePath = \$SPLUNK_DB/\$_index_name/db
coldPath = \$SPLUNK_DB/\$_index_name/colddb
thawedPath = /opt/frozen/main
maxTotalDataSizeMB = 1000
maxDataSize = 100

[web]
disabled = 0
homePath = \$SPLUNK_DB/\$_index_name/db
coldPath = \$SPLUNK_DB/\$_index_name/colddb
thawedPath = /opt/frozen/web
maxTotalDataSizeMB = 1000
maxDataSize = 100

EOF
```

The frozen path is outside the splunk home, thus it cannot be created by the splunk user. As **root**, create that path:
```
mkdir /opt/frozen
chown splunk:splunk /opt/frozen
```

Then, as user splunk, restart splunk.

## Listen for tcp input
Make your indexer listen for tcp input on port 9997. On the indexers, in `etc/system/local/inputs.conf`, add the following two lines:

```
[splunktcp:9997]
disabled = 0 
```

Its better to create a seperate app:
```
mkdir -p etc/apps/ia_indexing/default
cat >>etc/apps/ia_indexing/default/inputs.conf<<EOF
[splunktcp:9997]
disabled = 0
EOF
```

## Open Firewall port
If you have a firewall running (true in CentOS 7 by default), open up the following ports
```
firewall-cmd --add-port=9997/tcp --permanent # indexing port
firewall-cmd --add-port=8089/tcp --permanent # splunkd
firewall-cmd --reload
```
