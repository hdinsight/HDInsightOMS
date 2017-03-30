#!/bin/bash -x
set -e

# The script expects 3 arguments
# Argument 1 - OMS Workspace ID
# Argument 2 - OMX Primary Key

# Update packages
sudo apt-get update

# Install CollectD on machine
sudo apt-get -y install collectd collectd-utils

# Download OMS agent to /tmp directory
wget https://github.com/Microsoft/OMS-Agent-for-Linux/releases/download/OMSAgent-201702-v1.3.1-15/omsagent-1.3.1-15.universal.x64.sh  -O /tmp/omsagent.x64.sh
echo 'Installing OMS with CollectD Integration'
# Install OMS configured with CollectD
sudo sh /tmp/omsagent.x64.sh -w $1 -s $2 --collectd --upgrade

echo 'Installing OMS HDInsight filters'
sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/filter_hdinsight.rb -O /opt/microsoft/omsagent/plugin/filter_hdinsight.rb 
sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/hdinsightmanifestreader.rb -O  /opt/microsoft/omsagent/bin/hdinsightmanifestreader.rb 

echo 'Dowloading omsagent data'
sudo rm -f /tmp/omsagent
sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/omsagent -O /tmp/omsagent
sudo cp /tmp/omsagent /etc/sudoers.d/ 

echo 'Copying filter_hdinsight_collectd plugin'
sudo rm -f filter_hdinsight_collectd.rb
wget https://000aarperiscus.blob.core.windows.net/omsstorm1/filter_hdinsight_collectd.rb -O /tmp/filter_hdinsight_collectd.rb
sudo cp -f /tmp/filter_hdinsight_collectd.rb /opt/microsoft/omsagent/plugin/filter_hdinsight_collectd.rb

if [[ $HOSTNAME == wn* ]]; 
then 
  echo 'Worker node setup started.'
  
  echo 'Stopping omsagent service'
  sudo service omsagent stop
  
  echo 'Stopping CollectD service'
  sudo service collectd stop
  
  echo 'Copying Collectd JMX Metrics configuration'
  # Copy Collectd OMS Kafka Broker Metrics
  sudo rm -f /tmp/collectd_kafka_broker_jmx.conf.conf
  wget https://000aarperiscus.blob.core.windows.net/omskafka/collectd_kafka_broker_jmx.conf -O /tmp/collectd_kafka_broker_jmx.conf
  sudo cp -f /tmp/collectd_kafka_broker_jmx.conf /etc/collectd/collectd.conf.d/collectd_kafka_broker_jmx.conf
  #sudo sed "s/##KAFKA_JMX_PORT##/$3/" </tmp/omskafkabroker.conf >/etc/collectd/collectd.conf.d/omskafkabroker.conf
  
  echo 'Copying Collectd OMS web_http plugin configuration'
  # Copy OMS Web_Http plugin configuration.  
  sudo rm -f /tmp/collectd_oms_broker_http_plugin.conf
  wget https://000aarperiscus.blob.core.windows.net/omskafka/collectd_oms_broker_http_plugin.conf -O /tmp/collectd_oms_broker_http_plugin.conf
  sudo cp -f /tmp/collectd_oms_broker_http_plugin.conf /etc/collectd/collectd.conf.d/oms.conf
  
  echo 'Copying updated CollectD configuration for broker'
  sudo rm -f /tmp/collectd_broker.conf
  wget https://000aarperiscus.blob.core.windows.net/omskafka/collectd_broker.conf -O /tmp/collectd_broker.conf
  sudo cp -f /tmp/collectd_broker.conf /etc/collectd/collectd.conf

  echo 'Copying OMS CollectD conf'
  # Copy OMS' Collectd configruation to define what filters to use
  sudo rm -f /tmp/oms_collectd_broker.conf
  wget https://000aarperiscus.blob.core.windows.net/omskafka/oms_collectd_broker.conf -O /tmp/oms_collectd_broker.conf
  sudo cp -f /tmp/oms_collectd_broker.conf /etc/opt/microsoft/omsagent/conf/omsagent.d/collectd.conf
fi

# Restart Services
echo 'Restarting CollectD service'
sudo service collectd restart

echo 'Restarting OMSAgent service'
sudo service omsagent restart
