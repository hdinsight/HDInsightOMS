#!/bin/bash
wget https://github.com/Microsoft/OMS-Agent-for-Linux/releases/download/OMSAgent-201610-v1.2.0-148/omsagent-1.2.0-148.universal.x64.sh -O /tmp/omsagent.x64.sh
sudo sh /tmp/omsagent.x64.sh --upgrade
if [[ $HOSTNAME == wn* ]];
then
  sudo wget https://raw.githubusercontent.com/ashishthaps/hbase-utils/master/monitoring/presto.workernode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/presto.workernode.conf
fi
sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/filter_hdinsight.rb -O /opt/microsoft/omsagent/plugin/filter_hdinsight.rb
sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/hdinsightmanifestreader.rb -O  /opt/microsoft/omsagent/bin/hdinsightmanifestreader.rb
sudo wget https://raw.githubusercontent.com/Azure/hbase-utils/master/monitoring/omsagent
sudo cp omsagent /etc/sudoers.d/
sudo sh ~/.bashrc
sudo sh -x /opt/microsoft/omsagent/bin/omsadmin.sh -w $1 -s $2
sudo service omsagent restart
