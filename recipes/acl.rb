#
# Cookbook Name:: bb-db
# Recipe::acl 
#
# Copyright (C) 2013 Rackspace
# All rights reserved - Do Not Redistribute
#

node.override['rackspace-iptables']['chains'] = {
  "INPUT"   => "ACCEPT",
  "OUTPUT"  => "ACCEPT",
  "FORWARD" => "ACCEPT",
  "RACKSPACE" => "-",
  "WEBSERVERS" => "-"
 }

firewallRules = [
  "-A INPUT -j RACKSPACE",
  "-A INPUT -j WEBSERVERS",

  #BASTIONS
  "-A RACKSPACE -s 72.3.128.84/32 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 69.20.0.1/32 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 50.57.22.125/32 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 120.136.34.22/32 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 212.100.225.49/32 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 212.100.225.42/32 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 119.9.4.2/32 -i eth0 -j ACCEPT",

  #MAAS
  "-A RACKSPACE -s 50.56.142.128/26 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 50.57.61.0/26 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 78.136.44.0/26 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 180.150.149.64/26 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 69.20.52.192/26 -i eth0 -j ACCEPT",

  #SUPPORT
  "-A RACKSPACE -s 50.56.230.0/24 -i eth0 -j ACCEPT",
  "-A RACKSPACE -s 50.56.228.0/24 -i eth0 -j ACCEPT",
  "-A RACKSPACE -j RETURN",

  #Customer reqeusted
   "-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT"
]


#This will catch all Web and Wordpress-DB nodes and open up port 3306 for them
webserverRules = []
webservers = search("node", '(recipes:bb-web_node\:\:default || recipes:bb-db)' << " AND chef_environment:#{node.chef_environment}") || []
webservers.map! do |member|
  serverIP = begin
    if member.attribute?('cloud')
      if node.attribute?('cloud') && (member['cloud']['provider'] == node['cloud']['provider'])
         member['cloud']['local_ipv4']
      else
        member['cloud']['public_ipv4']
      end
    else
      member['ipaddress']
    end
  end
  webserverRules.push "-A WEBSERVERS -s #{serverIP}/32 -p tcp -m tcp --dport 3306 -i eth1 -j ACCEPT"
end
#we're sorting since the chef search may return in any order. This cuts down on constant non-effective rule updates
firewallRules.concat webserverRules.sort
firewallRules.push "-A WEBSERVERS -j RETURN"


#Default deny, to drop anything that's not explicitly allowed
firewallRules.push "-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT"
firewallRules.push "-A INPUT -s 0.0.0.0/0 -j REJECT"

#Take the array of rules that we have built up and push them into an attribute
node.override['rackspace-iptables']['rules']  = firewallRules
