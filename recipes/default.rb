#
# Cookbook Name:: 'monitoring_tivoli'
# Recipe:: default
#
#


# Check the current environment it's in
if node.chef_environment == 'production'
	node.default['monitor_servers'] = node['monitoring_tivoli']['prod_monitor_servers']
else
	node.default['monitor_servers'] = node['monitoring_tivoli']['pre_prod_monitor_servers']
end


case node['platform_family']
when 'rhel'
  node.default['monitoring_tivoli']['product_code'] = 'lz'
  include_recipe 'monitoring_tivoli::rhel'
end

