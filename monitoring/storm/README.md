# Apache Storm -> Microsoft OMS

## Setup

1. Clone this repo
1. Change the username/password values under `oms_collectd_nimbus.conf`
1. Change the `STORAGE_ROOT` value to point to wherever you'd like to host your settings (such as blob storage)
1. Upload the changed settings to the storage root
1. Run a [Script Action](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-script-actions-linux) pointing to the `hdiStormOms.sh` script in your storage account

## Queries to try

Topologies currently running

```
* Type=stormrestmetrics_CL status_s="ACTIVE"  TimeGenerated >NOW-1HOUR | dedup topologyId_s | select topologyId_s
```

Average Capacity by Topology

```
* Type=stormrestmetrics_CL | measure avg(capacity_d) as Capacity by topologyId_s interval 1MINUTE
```