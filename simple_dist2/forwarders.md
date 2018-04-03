# Forwarder Installation

Forwarders are installed with [install_splunk_fw.sh](./install_splunk_fw.sh).

This creates a splunk user, untars the forwarder tarball, accepts the license and enables boot start.

It also creates a `etc/system/local/deploymentclient.conf` with the following content:

```
[deployment-client]

[target-broker:deploymentServer]
targetUri= searchhead1:8089
```

Check the [docs](https://docs.splunk.com/Documentation/Splunk/7.0.2/Admin/Deploymentclientconf) for more options.
