directory node[:nginx][:log_dir] do
  recursive true
  mode 0755
  owner node[:nginx][:user]
  action :create
end

## Link logs back to /var/log if they've been moved, so that logrotate works
if node[:nginx][:log_dir] != "/var/log/nginx"
  # Gotta delete the bad boy first, otherwise it ends up as a link inside the directory
  directory "/var/log/nginx" do
    recursive true
    action :delete
  end

  link "/var/log/nginx" do
    to node[:nginx][:log_dir]
  end
end

# Some directory creation which is redundant for the APT package install
directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

%w{ sites-available sites-enabled conf.d }.each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group "root"
    mode "0755"
  end
end
# /Some directory creation which is redundant for the APT package install

## Move Nginx
content_dir = node[:nginx][:content_dir]
bash 'Move Nginx Data Dir' do
  not_if File.directory?(content_dir)
  code <<-EOF
    `mkdir -p #{content_dir}`
    `cp -rf /var/www/. #{content_dir}`
    `rm -rf /var/www`
    `ln -nsf #{content_dir} /var/www`
  EOF
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

remote_file "#{node[:nginx][:dir]}/mime.types" do
  source "mime.types"
  owner "root"
  group "root"
  mode "0644"
end

Chef::Log.info("Just before runit_service")

runit_service "nginx"

Chef::Log.info("Just before service resource")

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

Chef::Log.info("Just before disable default")

# Disable the default site
nginx_site "default" do
  enable false
end

Chef::Log.info("Just before enable stats vhost")

nginx_enable_vhost node.hostname do
  template "default-site.erb"
end