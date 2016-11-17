#!/bin/bash
##################################################################################################################
# Rackspace Cloud Monitoring Setup and simple bootstrap process using /etc/rc.d/rc.local
# Author: Gerhard Pretorius
# Version: 0.1
# Released: 21 July 2014
#
# Must be run as root
#
# This script will:
# 1) Install the Rackspace Cloud Monitoring agent:
#    www.rackspace.com/knowledge_center/article/install-the-cloud-monitoring-agent
#
# 2) Install raxmon - The Rackspace Cloud Monitoring CLI tool:
#    www.rackspace.com/knowledge_center/article/getting-started-with-rackspace-monitoring-cli
#
# 3) Set up a very simple server bootstrap configuration process using /etc/rc.d/rc.local
#    This will add the ability to define actions that will be performed at bootup in a script located at /root/autoscale/bootstrap/bootstrap.sh
#
# An example bootstrap.sh file is provided that sets up a CPU check using Rackspace Cloud Monitoring
#
###################################################################################################################

RAX_USERNAME="<RAX_USERNAME>"
RAX_API_KEY="<RAX_API_KEY>"


#INSTALL MONITORING AGENT:
sudo sh -c 'echo "deb http://stable.packages.cloudmonitoring.rackspace.com/ubuntu-14.04-x86_64 cloudmonitoring main" > /etc/apt/sources.list.d/rackspace-monitoring-agent.list'
wget -qO- https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc | sudo apt-key add -
sudo apt-get update && sudo apt-get install -y rackspace-monitoring-agent
sudo rackspace-monitoring-agent --setup --username $RAX_USERNAME --apikey $RAX_API_KEY
sudo rackspace-monitoring-agent start -D

#Install Rackspace-Monitoring CLI tool:
sudo pip install rackspace-monitoring-cli
cat << EOF > ~/.raxrc
[credentials]
username=$RAX_USERNAME
api_key=$RAX_API_KEY

[auth_api]
url=https://lon.identity.api.rackspacecloud.com/v2.0/tokens
EOF

raxmon-entities-list

cat << EOF >> /etc/rc.local

#bootstrap tasks
sudo apt-get install -y git
rm -rf /root/autoscale
git clone https://github.com/ggpretorius/autoscale /root/autoscale
/root/autoscale/bootstrap/bootstrap.sh 2>&1 > /var/log/bootstrap.log
EOF
