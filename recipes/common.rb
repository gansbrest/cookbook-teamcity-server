include_recipe "java"

group node["teamcity_server"]["group"] do
  action :create
end

user node["teamcity_server"]["user"] do
  action :create
  gid node["teamcity_server"]["group"]
  home node["teamcity_server"]["root_dir"]
  shell "/bin/bash"
  not_if "getent passwd #{node["teamcity_server"]["user"]}"
end

directory node["teamcity_server"]["root_dir"] do
  owner  node["teamcity_server"]["user"]
  group  node["teamcity_server"]["group"]
  mode "0755"
  action :create
end

directory node["teamcity_server"]["data_dir"] do
  owner  node["teamcity_server"]["user"]
  group  node["teamcity_server"]["group"]
  mode "0755"
  action :create
end

directory "#{node["teamcity_server"]["data_dir"]}/config" do
  owner  node["teamcity_server"]["user"]
  group  node["teamcity_server"]["group"]
  mode "0755"
  action :create
end

archive_name = "TeamCity-#{node["teamcity_server"]["version"]}.tar.gz"
full_url     = "#{node["teamcity_server"]["base_url"]}#{archive_name}"
archive      = "#{Chef::Config[:file_cache_path]}/#{archive_name}"

remote_file archive do
  backup false
  source full_url
  owner  node["teamcity_server"]["user"]
  group  node["teamcity_server"]["group"]
  action :create_if_missing
  notifies :run, "execute[unarchive]", :immediately
end

execute "unarchive" do
  command "tar xf #{archive} --strip=1"
  user   node["teamcity_server"]["user"]
  group  node["teamcity_server"]["group"]
  cwd node["teamcity_server"]["root_dir"]
  action :nothing
end

#create the logs dir after unarchiving in case we want to put it in there
directory node["teamcity_server"]["logs_dir"] do
  owner  node["teamcity_server"]["user"]
  group  node["teamcity_server"]["group"]
  mode "0755"
  action :create
end
