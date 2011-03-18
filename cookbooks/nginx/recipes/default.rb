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

include_recipe "nginx::config_server"