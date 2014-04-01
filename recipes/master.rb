#
# Cookbook Name:: bb-db::master
# Recipe:: default
#
# Copyright (C) 2013 Rackspace
# All rights reserved - Do Not Redistribute
#

if node['mysql']['server_root_password']
  execute 'update-root-password' do
    command %Q("#{node['mysql']['mysqladmin_bin']}" -u root -p'#{node['mysql']['server_root_password']}' password #{root_creds["pass"]})
    action :run
    only_if %Q("#{node['mysql']['mysql_bin']}" -u root -p#{node['mysql']['server_root_password']} -e 'show databases;')
  end
end

mysql_connection_info = {
  host: 'localhost',
  username: 'root',
  password: root_creds['pass']
}

mysql_database 'vtiger_db' do
  connection mysql_connection_info
  retries 2
  retry_delay 2
  action :create
end

mysql_database_user 'vtiger_user' do
  connection mysql_connection_info
  password node['bb-brownbag']['passwords']['bb_user']
  host 'localhost'
  retries 2
  retry_delay 2
  action :create
end

# give bb_user usage on all
mysql_database_user 'bb_user' do
  connection mysql_connection_info
  privileges [:usage]
  retries 2
  retry_delay 2
  action :grant
end

# give bb_user usage on all
mysql_database_user 'bb_user' do
  connection mysql_connection_info
  privileges [:usage]
  retries 2
  retry_delay 2
  action :grant
end

# BB_user gets full usage on bb_db
mysql_database_user 'bb_user' do
  connection mysql_connection_info
  database_name 'bb_db'
  privileges [:all]
  retries 2
  action :grant
end

template '/root/.my.cnf' do
  source 'my.cnf.erb'
  mode 0600
  owner 'root'
  group 'root'
  variables(
              user: root_creds['user'],
              pass: root_creds['pass']
  )
end
