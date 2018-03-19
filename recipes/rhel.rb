# Agent install for RHEL servers

# Agent install requires both 32 and 64 bit, tested and confirmed this is true
agent_packages = [
  'ksh',
  'libXi',
  'libXtst',
  'libXfixes',
  'libXcursor',
  'libXft',
  'compat-libstdc++-33',
  'libgcc',
  'libstdc++',
  'compat-libstdc++-33.i686',
  'libgcc.i686',
  'libstdc++.i686',
  'sssd-client.i686'
]

agent_packages.each do |p|
  package p
end

# Create strings for tar gz extensions
linux_agent = "#{node['monitoring_tivoli']['linux_base']}" + '.tar.gz'
linux_agent_FP5 = "#{node['monitoring_tivoli']['linux_FP5']}" + '.tar.gz'
# Ensure this diretory exists
directory 'Folder permissions' do
  path '/opt/IBM/ITM'
  owner 'itmuser'
  group 'tivoli'
  recursive true
  mode 0755
end
# Create the silent install file
template '/tmp/silent_install' do
  source 'silent_install.erb'
  owner 'root'
  group 'root'
  mode 0644
  action :nothing
end
# Download the FP5 package
remote_file 'fp_agent' do
 source "https://somesite.com/tivoli/#{linux_agent_FP5}"
 path "#{Chef::Config['file_cache_path']}/#{node['monitoring_tivoli']['linux_FP5']}"
 mode 0755
 action :nothing
end
# Unzip the FP5 package
execute 'Untar_FP_Agent' do
  command "tar -xzvf #{node['monitoring_tivoli']['linux_FP5']}"
  cwd "#{Chef::Config['file_cache_path']}"
  creates "#{Chef::Config['file_cache_path']}/#{node['monitoring_tivoli']['linux_FP5']}/install.sh"
  action :nothing
end
# Download the base agent package
remote_file 'base_agent' do
 source "https://somesite.com/tivoli/#{linux_agent}"
 path "#{Chef::Config['file_cache_path']}/#{node['monitoring_tivoli']['linux_base']}"
 mode 0755
 action :nothing
end
# Unzip the base agent package
execute 'Untar_Base_Agent' do
  command "tar -xzvf #{node['monitoring_tivoli']['linux_base']}"
  cwd "#{Chef::Config['file_cache_path']}"
  creates "#{Chef::Config['file_cache_path']}/#{node['monitoring_tivoli']['linux_base']}/install.sh"
  action :nothing
end
# Remove the FP folder after completion
directory 'remove_fp_folder' do
  path "#{Chef::Config['file_cache_path']}/#{node['monitoring_tivoli']['linux_FP5']}"
  recursive true
  action :nothing
end
# Remove the base folder after completion
directory 'remove_base_folder' do
  path "#{Chef::Config['file_cache_path']}/#{node['monitoring_tivoli']['linux_base']}"
  recursive true
  action :nothing
end
# Install the FixPack update
execute 'Install_FixPack5_Update' do
  command "./install.sh -q -h #{node['monitoring_tivoli']['install_path']} -p /tmp/silent_install"
  cwd "#{Chef::Config['file_cache_path']}/#{node['monitoring_tivoli']['linux_FP5']}"
  action :nothing
end
# Run the install of Tivoli base agent
execute 'Install_TIV_OS_Agent' do
  command "setarch $(uname -m) --uname-2.6 ./install.sh -q -h #{node['monitoring_tivoli']['install_path']} -p /tmp/silent_install"
  cwd "#{Chef::Config['file_cache_path']}/#{node['monitoring_tivoli']['linux_base']}"
  creates "#{node['monitoring_tivoli']['install_path']}/bin/cinfo"
  notifies :create, 'template[/tmp/silent_install]', :before
  #notifies :create, 'template[/tmp/silent_config]', :before
  notifies :create_if_missing, 'remote_file[fp_agent]', :before
  notifies :run, 'execute[Untar_FP_Agent]', :before
  notifies :create_if_missing, 'remote_file[base_agent]', :before
  notifies :run, 'execute[Untar_Base_Agent]', :before
  notifies :run, 'execute[Install_FixPack5_Update]', :immediately
  #notifies :run, 'execute[Configure_agent]', :immediately
  #notifies :run, 'execute[Start_agent]', :immediately
  notifies :delete, 'directory[remove_base_folder]', :delayed
  notifies :delete, 'directory[remove_fp_folder]', :delayed
end
# Start the agent for the first time because it's a POS
execute 'Start_agent_first_time' do
  command "./itmcmd agent start #{node['monitoring_tivoli']['product_code']}"
  cwd "#{node['monitoring_tivoli']['install_path']}/bin"
  not_if 'ps aux | grep [klz]agent'
end
# Create the silent config file
template '/tmp/silent_config' do
  source 'silent_config.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :run, 'execute[Configure_agent]', :immediately
  notifies :run, 'execute[Stop_agent]', :immediately
  notifies :run, 'execute[Start_agent]', :immediately
end
# Configure the agent
execute 'Configure_agent' do
  command "./itmcmd config -A -p /tmp/silent_config #{node['monitoring_tivoli']['product_code']}"
  cwd "#{node['monitoring_tivoli']['install_path']}/bin"
  action :nothing
end
# Stop the agent, this is because there is no restart command built into this POS software
execute 'Stop_agent' do
  command "./itmcmd agent stop #{node['monitoring_tivoli']['product_code']}"
  cwd "#{node['monitoring_tivoli']['install_path']}/bin"
  action :nothing
end
# Start the agent
execute 'Start_agent' do
  command "./itmcmd agent start #{node['monitoring_tivoli']['product_code']}"
  cwd "#{node['monitoring_tivoli']['install_path']}/bin"
  action :nothing
end