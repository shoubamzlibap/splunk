# Indexer

## Disable Web
Usually the indexers don't need a webinterface, so its good practise to disable it. On both of the indexers, in `etc/system/local`, create a file called `web.conf` with the following content:
```
[settings]
startwebserver = 0
```

After the change, restart splunk. If you want to test if this was successful, the following command should yield no output:
```
ss -tulpen |grep 8000
```
whereas bevor it should have printed a line.

## Listen for tcp input
Make your indexer listen for tcp input on port 9997. On the indexers, in `etc/system/local/inputs.conf`, add the following two lines:

```
[splunktcp:9997]
disabled = 0 
```

## Open Firewall port
If you have a firewall running (true in CentOS 7 by default), open up the following ports
```
firewall-cmd --add-port=9997/tcp --permanent # indexing port
firewall-cmd --add-port=8089/tcp --permanent # splunkd
firewall-cmd --reload
```

## Minimum Free Diskspace for a small test environment
This is a setting that will probably not bug you in production, but my test boxes are rather small, with a root fs of just 8GB. Soon your splunk indexers will complain with a message like

```
Search peer idx1 has the following message: Disk Monitor: The index processor has paused data flow. Current free disk space on partition '/' has fallen to 4426MB, below the minimum of 5000MB. Data writes to index path '/opt/splunk/var/lib/splunk/audit/db'cannot safely proceed. Increase free disk space on partition '/' by removing or relocating data.
```

My "solution" is to change the `minFreeSpace` value in `etc/system/local/server.conf` to something below 5GB. I currently do not know, but there is probablyl a reason for this limit, so bevor 
you do this on production I highly recommend you really know what you do. After all, what is 5GB in production? For my laptops ssd is a bunch, so I am setting this:
```
[diskUsage]
minFreeSpace = 1000
```

