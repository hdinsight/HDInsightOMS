#!/bin/bash
set -e

# This script expects 2 arguments
# 1 - The OMS Workspace ID
# 2 - The OMS Primary Key

REPO_ROOT="https://raw.githubusercontent.com/rywater/HDInsightOMS/master/monitoring/storm"

echo 'Updating package definitions'
sudo apt-get update

echo 'Installing CollectD service'
sudo apt-get -y install collectd collectd-utils

echo 'Downloading OMS Agent to /tmp'
wget https://github.com/Microsoft/OMS-Agent-for-Linux/releases/download/OMSAgent_GA_v1.2.0-25/omsagent-1.2.0-25.universal.x64.sh -O /tmp/omsagent.x64.sh

echo 'Installing OMS with CollectD integration'
sudo sh /tmp/omsagent.x64.sh -w $1 -s $2 --collectd --upgrade

echo 'Installing OMS HDInsight filter'
sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/filter_hdinsight.rb -O /opt/microsoft/omsagent/plugin/filter_hdinsight.rb
sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/hdinsightmanifestreader.rb -O  /opt/microsoft/omsagent/bin/hdinsightmanifestreader.rb

echo 'Downloading OMS Agent data'
sudo rm -f /tmp/omsagent
sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/omsagent -O /tmp/omsagent
sudo cp /tmp/omsagent /etc/sudoers.d/

echo 'Stopping omsagent service'
sudo service omsagent stop

echo 'Stopping collectd service'
sudo service collectd stop

echo 'Copying filter_hdinsight_collectd plugin'
sudo rm -f /tmp/filter_hdinsight_collectd.rb
wget "$REPO_ROOT/filters/filter_hdinsight_collectd.rb" -O /tmp/filter_hdinsight_collectd.rb
sudo cp -f /tmp/filter_hdinsight_collectd.rb /opt/microsoft/omsagent/plugin/filter_hdinsight_collectd.rb

if [[ $HOSTNAME == hn* ]];
then
    echo 'Head node setup started'

    echo 'Copying OMS and CollectD configuration for Nimbus'
    sudo rm -f /tmp/oms_collectd_nimbus.conf
    # _primary config includes the REST API metrics
    postfix=$([[ $HOSTNAME == hn0* ]] && echo "_primary.conf" || echo ".conf")
    config="$REPO_ROOT/nimbus/oms_collectd_nimbus$postfix"
    wget "$config" -O /tmp/oms_collectd_nimbus.conf
    sudo cp -f /tmp/oms_collectd_nimbus.conf /etc/opt/microsoft/omsagent/conf/omsagent.d/collectd.conf

    if [[ $HOSTNAME == hn0* ]];
    then 
        # Storm UI, which this pulls from, runs on hn0 by default 
        echo 'Copying Storm REST API FluentD plugin'
        sudo rm -f /tmp/in_storm.rb
        wget "https://raw.githubusercontent.com/rywater/fluent-plugin-storm/master/lib/fluent/plugin/in_storm.rb" -O /tmp/in_storm.rb
        sudo cp -f /tmp/in_storm.rb /opt/microsoft/omsagent/plugin/in_storm.rb
    fi

    echo 'Copying Storm FluentD plugins'
    sudo rm -f /tmp/filter_storm*.rb
    wget "$REPO_ROOT/filters/filter_storm_flatten.rb" -O /tmp/filter_storm_flatten.rb
    sudo cp -f /tmp/filter_storm_flatten.rb /opt/microsoft/omsagent/plugin/filter_storm_flatten.rb

    wget "$REPO_ROOT/filters/filter_storm_oms.rb" -O /tmp/filter_storm_oms.rb
    sudo cp -f /tmp/filter_storm_oms.rb /opt/microsoft/omsagent/plugin/filter_storm_oms.rb

    echo 'Copying CollectD JMX Metrics Configurations'
    sudo rm -f /tmp/collectd_oms_nimbus_jmx.conf
    wget "$REPO_ROOT/nimbus/collectd_oms_nimbus_jmx.conf" -O /tmp/collectd_oms_nimbus_jmx.conf
    sudo cp -f /tmp/collectd_oms_nimbus_jmx.conf /etc/collectd/collectd.conf.d/collectd_oms_nimbus_jmx.conf

    echo 'Copying CollectD OMS HTTP plugin configuration'
    sudo rm -f /tmp/collectd_oms_nimbus_http.conf
    wget "$REPO_ROOT/nimbus/collectd_oms_nimbus_http.conf" -O /tmp/collectd_oms_nimbus_http.conf
    sudo cp -f /tmp/collectd_oms_nimbus_http.conf /etc/collectd/collectd.conf.d/oms.conf

    echo 'Copying CollectD configuration for Nimbus'
    sudo rm -f /tmp/collectd_nimbus.conf
    wget "$REPO_ROOT/nimbus/collectd_nimbus.conf" -O /tmp/collectd_nimbus.conf
    sudo cp -f /tmp/collectd_nimbus.conf /etc/collectd/collectd.conf

fi

if [[ $HOSTNAME == wn* ]];
then

    echo 'Worker node setup started'

    echo 'Generating JMX config for worker'
    sudo rm -f /tmp/worker_jmx.conf
    sudo rm -f /tmp/workergen.py
    wget "$REPO_ROOT/templates/worker_jmx.conf" -O /tmp/worker_jmx.conf
    wget "$REPO_ROOT/workergen.py" -O /tmp/workergen.py
    python /tmp/workergen.py --template /tmp/worker_jmx.conf --output /tmp/collectd_oms_worker_jmx.conf
    sudo cp -f /tmp/collectd_oms_worker_jmx.conf /etc/collectd/collectd.conf.d/collectd_oms_worker_jmx.conf

    echo 'Copying CollectD OMS HTTP plugin configuration'
    sudo rm -f /tmp/collectd_oms_worker_http.conf
    wget "$REPO_ROOT/worker/collectd_oms_worker_http.conf" -O /tmp/collectd_oms_worker_http.conf
    sudo cp -f /tmp/collectd_oms_worker_http.conf /etc/collectd/collectd.conf.d/oms.conf

    echo 'Copying CollectD configuration for worker'
    sudo rm -f /tmp/collectd_worker.conf
    wget "$REPO_ROOT/worker/collectd_worker.conf" -O /tmp/collectd_worker.conf
    sudo cp -f /tmp/collectd_worker.conf /etc/collectd/collectd.conf

    echo 'Copying OMS Agent CollectD filter configurations'
    sudo rm -f /tmp/oms_collectd_worker.conf
    wget "$REPO_ROOT/worker/oms_collectd_worker.conf" -O /tmp/oms_collectd_worker.conf
    sudo cp -f /tmp/oms_collectd_worker.conf /etc/opt/microsoft/omsagent/conf/omsagent.d/collectd.conf

fi

echo 'Restarting CollectD Service'
sudo service collectd restart

echo 'Restarting OMS Agent Service'
sudo service omsagent restart
