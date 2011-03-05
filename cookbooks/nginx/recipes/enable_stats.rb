include_recipe "nginx::default"

# Load the nginx plugin in the main config file
node[:rs_utils][:plugin_list] += " nginx" unless node[:rs_utils][:plugin_list] =~ /nginx/
node[:rs_utils][:plugin_list] += " tail" unless node[:rs_utils][:plugin_list] =~ /tail/
node[:rs_utils][:process_list] += " nginx" unless node[:rs_utils][:process_list] =~ /nginx/

include_recipe "rs_utils::setup_monitoring"

nginx_conf    = ::File.join(node[:nginx][:dir], "conf.d", "stats.conf")
nginx_collectd_conf = ::File.join(node[:rs_utils][:collectd_plugin_dir], "nginx.conf")
fpm_collectd_conf = ::File.join(node[:rs_utils][:collectd_plugin_dir], "phpfpm.conf")

remote_file nginx_conf do
  source "stats.conf"
  mode 0644
  owner "root"
  group "root"
end

# Instrumentation method "borrowed" from;
# http://bethesignal.org/blog/2009/07/22/watching-nginx-upstreams-with-collectd/
template fpm_collectd_conf do
  source "phpfpm-collectd.conf.erb"
end

remote_file nginx_collectd_conf do
  source "nginx-collectd.conf"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "collectd")
end