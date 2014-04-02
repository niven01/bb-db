#
# Cookbook Name:: bb-db
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

critical_recipes = [
  'rackspace_apt',
  'rackspace_mysql'
]

# If these recipes fail, for example due to an external api, finish convergence but log an error
non_critical_recipes = [
]

case node['platform']
 when 'ubuntu'

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
 when 'redhat'
                # A list of recipe specific to a RedHat install would be listed here
    Chef::Log.warn('MySQL can only be installed on Ubuntu using this cookbook, this platform is debian.')
end

