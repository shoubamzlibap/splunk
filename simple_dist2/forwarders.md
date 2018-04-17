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

## Log generation
In order to generate logs, we need to create directories to hold the logs, and also have some software generate logs
(in case we do not have real logs).

For this exercise I am generating the logs with the splunk user, so I do not have to deal with access rights. Should that be
an issue, acls are usually a good tool to get splunk access to other users logs.

As **root**, on datamill1:
```
mkdir -p /opt/log/www{1..3}
chown -R splunk:splunk /opt/log/
```

As **root**, on datamill2:
```
mkdir -p /opt/log/cisco_router1 /opt/log/crashlog
chown -R splunk:splunk /opt/log/
```

On both datamills create /opt/datagen and download [gogen](https://github.com/coccyx/gogen) to this directory.

As *splunk*, on datamill1, execute the following command to get some sample weblogs:
```
mkdir gogens
./gogen pull coccyx/weblog gogens
```
Also, deploy the directory [mygogens](./mygogens) with its content, then run [./create_logs1.sh](./create_logs1.sh).
It will run and generate logs untill you kill it with Ctrl + C.

## Forwarder management
Once the logs are generated, we can start using forwarder management to configure the forwarders. Depending on the overall architecture, the 
forwarder management can happen on a dedicated splunk server. In the case of my little demo setup, I will use the searchhead as a forwarder manager. So, the serachhead must be up and running.

On the searchhead, create a directory for each forwarder, as in our little demo setup, each forwarder will get its own forwarding app.
Each directory will hold an app that will be deployed. Also, reload the deployment server: 

```
cd /opt/splunk/etc/deployment-apps
mkdir dm1_fw_app dm2_fw_app
splunk reload deploy-server
```

On the splunk web on the search head, go to "Settings", "Forwarder Management". You should see two classes corresponding to the directories just created.
Under "Server Classes", create a new server class, e.g. called "web", and add the app "datamill1" and the server "datamill1" to the class.

### Forwarding web and secure logs
In the `dm_fw_app` directory, create a `local` subdirectory, with the following two files in it:

```
# inputs.conf
cat >>/opt/splunk/etc/deployment-apps/dm1_fw_app/local/inputs.conf<<EOF
[monitor:///opt/log/.../access.log]
host_segment = 3
sourcetype = access_combined
#index = testindex
index = web

[monitor:///opt/log/.../secure.log]
host_segment = 3
sourcetype = linux_secure
#index = testindex
index = main
EOF

# outputs.conf
cat >>/opt/splunk/etc/deployment-apps/dm1_fw_app/local/outputs.conf<<EOF
[tcpout]
defaultGroup = my_search_peers
forwardedindex.filter.disable = true
indexAndForward = false

[tcpout:my_search_peers]
server=10.23.23.5:9997,10.23.23.6:9997
EOF
```

This `inputs.conf` will monitor the files `access.log` and `secure.log`, send them to different indexes and infer the hostname from the third segment of the
file path. It also sets the sourcetype.

The `outputs.conf` forwards the data in a loadbalanced fashion to the two indexers.

Once this is done, trigger the deployment with `splunk reload deploy-server` on the search head. This will push the config to `datamill1`
and reload the splunk daemon. It might a take a while - you can reload splunk on `datamill1` for faster results.

Also, if still onboarding data, you can use the testindex first, and then switch once everything works as expected.
