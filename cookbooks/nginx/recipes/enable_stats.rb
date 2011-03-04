include_recipe "nginx::default"

# Load the nginx plugin in the main config file
node[:rs_utils][:plugin_list] += " nginx" unless node[:rs_utils][:plugin_list] =~ /nginx/
node[:rs_utils][:process_list] += " nginx" unless node[:rs_utils][:process_list] =~ /nginx/

include_recipe "rs_utils::setup_monitoring"

nginx_conf    = ::File.join(node[:nginx][:dir], "conf.d", "stats.conf")
collectd_conf = ::File.join(node[:rs_utils][:collectd_plugin_dir], "nginx.conf")

remote_file nginx_conf do
  source "stats.conf"
  mode 0644
  owner "root"
  group "root"
end

remote_file collectd_conf do
  source "nginx-collectd.conf"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "collectd")
end