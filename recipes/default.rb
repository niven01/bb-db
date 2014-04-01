#
# Cookbook Name:: bb-db
# Recipe:: default
#
# Copyright (C) 2013 Rackspace
# All rights reserved - Do Not Redistribute
#

# check in every 5 minutes
node.default['chef_client']['interval'] = 300
node.default['chef_client']['splay'] = 60

# innodb settings
node.default['mysql']['tunable']['innodb_buffer_pool_size']  = '2401M'

# Ubuntu will spawn the service instantly on install creating 5MB logfiles. Changing this value will require manual intervention when bringing up
# new servers
# node.default['mysql']['tunable']['innodb_log_file_size']     = "128M"

# I'm using ipaddr to convert the public IP to an integer. This gives us a unique value to use for server_id.
require 'ipaddr'
ip = IPAddr.new node['cloud']['public_ipv4']
# replication settings
node.default['mysql']['tunable']['server_id']       = ip.to_i
node.default['mysql']['tunable']['expire_log_days'] = '5'
node.default['mysql']['tunable']['log_bin']         = '/var/lib/mysql/bin-log'

# buffer and cache settings
node.default['mysql']['tunable']['thread_cache_size']       = '16'
node.default['mysql']['tunable']['table_open_cache']        = '2048'
node.default['mysql']['tunable']['query_cache_size']        = '32'
node.default['mysql']['tunable']['sort_buffer_size']        = '1M'
node.default['mysql']['tunable']['read_buffer_size']        = '1M'
node.default['mysql']['tunable']['read_rnd_buffer_size']    = '8M'
node.default['mysql']['tunable']['join_buffer_size']        = '1M'
node.default['mysql']['tunable']['tmp_table_size']          = '64M'
node.default['mysql']['tunable']['max_connections']         = '1000'
node.default['mysql']['tunable']['max_connect_errors']      = '10000'
node.default['mysql']['tunable']['myisam_sort_buffer_size'] = '128M'

# this variable prevents MySQL from being automatically restarted
node.default['mysql']['reload_action'] = 'none'

# If these recipes fail, the whole convergence will be considered unsuccessful
critical_recipes = [
  'rackspace_iptables',
  'cron',
  'rackspace_mysql::server'
 # "database::mysql"
]

# If these recipes fail, for example due to an external api, finish convergence but log an error
non_critical_recipes = [
]

# Run critical recipes
critical_recipes.each do | recipe |
  include_recipe recipe
end

# Run non-critical recipes
non_critical_recipes.each do | recipe |
  include_recipe recipe do
    ignore_failure true
  end
end
