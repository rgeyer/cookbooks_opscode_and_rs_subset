#
# Cookbook Name:: nginx
# Recipe:: default
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


e = bash "add-apt-repository" do
  code <<-EOF
apt-get -y -q install python-software-properties
add-apt-repository ppa:nginx/stable
apt-get update -o Acquire::http::No-Cache=1
EOF
  action :nothing
end

e.run_action(:run)

package "nginx-full"

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

## Move Nginx
content_dir = node[:nginx][:content_dir]
bash 'Move Nginx Data Dir' do
  not_if do File.directory?(content_dir) end
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

nginx_enable_vhost "default" do
  fqdn "default"
  template "default-site.erb"
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
