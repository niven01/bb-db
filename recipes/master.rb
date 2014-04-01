#
# Cookbook Name:: bb-db::master
# Recipe:: default
#
# Copyright (C) 2013 Rackspace
# All rights reserved - Do Not Redistribute
#


mysql_secret    = Chef::EncryptedDataBagItem.load_secret("/root/db_wordpress.key")
root_creds      = Chef::EncryptedDataBagItem.load("db_wordpress", "root", mysql_secret)
replicant_creds = Chef::EncryptedDataBagItem.load("db_wordpress", "replicant", mysql_secret)
holland_creds   = Chef::EncryptedDataBagItem.load("db_wordpress", "holland", mysql_secret)

slave_nodes     = search(:node, 'recipes:1867532-db_wordpress\:\:slave')

if node['mysql']['server_root_password']
  execute "update-root-password" do
    command %Q["#{node['mysql']['mysqladmin_bin']}" -u root -p'#{node['mysql']['server_root_password']}' password #{root_creds["pass"]}]
    action :run
    only_if %Q["#{node['mysql']['mysql_bin']}" -u root -p#{node['mysql']['server_root_password']} -e 'show databases;']
  end
end

mysql_connection_info = {
  :host => "localhost",
  :username => 'root',
  :password => root_creds["pass"]
}

mysql_database 'wordpress_db' do
  connection mysql_connection_info
  retries 2
  retry_delay 2
  action :create
end

mysql_database_user 'holland' do
  connection mysql_connection_info
  password holland_creds["pass"]
  host "localhost"
  retries 2
  retry_delay 2
  action :create
end

#give holland usage on all
mysql_database_user 'holland' do
  connection mysql_connection_info
  privileges [:'SELECT', :'SHOW VIEW', :'TRIGGER', :'LOCK TABLES', :'SUPER', :'REPLICATION CLIENT', :'RELOAD']
  retries 2
  retry_delay 2
  action :grant
end


mysql_database_user 'wordpress_user' do
  connection mysql_connection_info
  password node['1867532-Funimation']['passwords']['wordpress_user']
  host "10.%"
  retries 2
  retry_delay 2
  action :create
end

mysql_database_user 'wordpress_user' do
  connection mysql_connection_info
  password node['1867532-Funimation']['passwords']['wordpress_user']
  host "localhost"
  retries 2
  retry_delay 2
  action :create
end

#give wordpress_user usage on all
mysql_database_user 'wordpress_user' do
  connection mysql_connection_info
  privileges [:usage]
  retries 2
  retry_delay 2
  action :grant
end

mysql_database_user 'wordpress_user' do
  connection mysql_connection_info
  password node['1867532-Funimation']['passwords']['wordpress_user']
  host "10.%"
  retries 2
  retry_delay 2
  action :create
end

#give wordpress_user usage on all
mysql_database_user 'wordpress_user' do
  connection mysql_connection_info
  privileges [:usage]
  retries 2
  retry_delay 2
  action :grant
end

#wordpress gets full usage on wordpress_db
mysql_database_user 'wordpress_user' do
  connection mysql_connection_info
  database_name 'wordpress_db'
  privileges [:all]
  retries 2
  action :grant
end

slave_nodes.each do |node|
  mysql_database_user 'replicant' do
    connection mysql_connection_info
    password replicant_creds["pass"]
    host "#{node['cloud']['local_ipv4']}"
    privileges [:'replication slave', :usage]
    retries 2
    action :create
  end

  mysql_database_user 'replicant' do
    connection mysql_connection_info
    host "#{node['cloud']['local_ipv4']}"
    privileges [:'replication slave', :usage]
    retries 2
    action :grant
  end
end

template "/root/.my.cnf" do
  source "my.cnf.erb"
  mode 0600
  owner "root"
  group "root"
  variables ({
   :user => root_creds["user"],
   :pass => root_creds["pass"]
  })
end
