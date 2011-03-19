accept_fqdn=node[:nginx][:accept_fqdn]
underscored_accept_fqdn=accept_fqdn.gsub(".","_")

rsa_cert="#{node[:nginx][:dir]}/ssl/#{node[:nginx][:accept_fqdn]}.crt"
rsa_key="#{node[:nginx][:dir]}/ssl/#{node[:nginx][:accept_fqdn]}.key"

include_recipe "nginx::config_server"

directory "#{node[:nginx][:dir]}/ssl" do
  mode 0644
  owner "root"
  group "root"
  recursive true
  action :create
end

rsa_keypair_from_pkcs12 "Convert PKCS12 to RSA keypair" do
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:nginx][:s3_cert_bucket]
  s3_file "#{underscored_accept_fqdn}.pkcs12"
  rsa_cert_path rsa_cert
  rsa_key_path rsa_key
  pkcs12_pass node[:nginx][:pkcs12_pass]
end

nginx_enable_vhost accept_fqdn do
  cookbook "nginx"
  template "ssl-vhost-proxy.conf.erb"
  fqdn accept_fqdn
  aliases node[:nginx][:aliases]
  dest_fqdn node[:nginx][:dest_fqdn]
  dest_port node[:nginx][:dest_port]
  listen_on_http node[:nginx][:proxy_http] == "true"
  force_https node[:nginx][:force_https] == "true"
end

right_link_tag "reverse_proxy:for=https://#{accept_fqdn}"
right_link_tag "reverse_proxy:target=https://#{node[:nginx][:dest_fqdn]}:#{node[:nginx][:dest_port]}"

if node[:nginx][:proxy_http] == "true"
  right_link_tag "reverse_proxy:for=http://#{accept_fqdn}"
  right_link_tag "reverse_proxy:target=http://#{node[:nginx][:dest_fqdn]}" unless node[:nginx][:force_https] == "true"
end

node[:nginx][:aliases].each do |a|
  right_link_tag "reverse_proxy:for=https://#{a}"
  right_link_tag "reverse_proxy:for=http://#{a}" if node[:nginx][:proxy_http] == "true"
end if node[:nginx][:aliases]