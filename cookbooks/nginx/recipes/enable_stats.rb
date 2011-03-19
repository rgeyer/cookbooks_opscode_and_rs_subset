include_recipe "nginx::config_server"

# Load the nginx plugin in the main config file
node[:rs_utils][:plugin_list] += " nginx" unless node[:rs_utils][:plugin_list] =~ /nginx/
node[:rs_utils][:process_list] += " nginx" unless node[:rs_utils][:process_list] =~ /nginx/

include_recipe "rs_utils::setup_monitoring"

nginx_conf    = ::File.join(node[:nginx][:dir], "sites-available", "#{node[:hostname]}.d", "nginx_stats.conf")
nginx_collectd_conf = ::File.join(node[:rs_utils][:collectd_plugin_dir], "nginx.conf")

template nginx_conf do
  source "stats.conf.erb"
  mode 0644
  owner "root"
  group "root"
end

template nginx_collectd_conf do
  source "nginx-collectd.conf.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "collectd")
end