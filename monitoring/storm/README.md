# Apache Storm -> Microsoft OMS

## Prerequisites

1. OMS Workspace, with Workspace ID and Primary Key. See [here](https://docs.microsoft.com/en-us/azure/operations-management-suite/operations-management-suite-overview) for more information.

## Setup

1. Verify that JMX endpoints are exposed in the cluster's Ambari configuration, if not, see the [below](#Ambari-JMX-Configuration-settings) setup
1. Run a [Script Action](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-script-actions-linux) using `hdStormOms.sh` with OMS Workspace ID and Primary Key arguments
1. Create a new OMS View in the View Designer and import the provided `storm.omsview` to create an example OMS view based on the installed Storm metrics

### Ambari JMX Configuration settings

These should be enabled by default in newer clusters. However, if not, verify the following settings are present under the Storm configuration:

* nimbus.childopts: `-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=56431`
* supervisor.childopts: `-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port={{jmxremote_port}}`
* worker.childopts: `-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=%ID%`


## Queries to try

Topologies currently running

```
* Type=stormrestmetrics_CL status_s="ACTIVE"  TimeGenerated >NOW-1HOUR | dedup topologyId_s | select topologyId_s
```

Average Capacity by Topology

```
* Type=stormrestmetrics_CL | measure avg(capacity_d) as Capacity by topologyId_s interval 1MINUTE
```