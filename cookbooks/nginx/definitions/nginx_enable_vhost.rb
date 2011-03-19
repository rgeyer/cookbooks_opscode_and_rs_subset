define :nginx_enable_vhost, :fqdn => nil, :aliases => nil do
  fqdn = params[:fqdn] || params[:name]
  docroot = ::File.join(node[:nginx][:content_dir],fqdn,"htdocs")
  systemroot = ::File.join(docroot, "system")

  # A workaround for a bug in RightScale's implementation of chef, where exluded optional
  # attributes cause all attributes to be nil.  This allows the user to provide a value
  # for the optional input which will be ignored.
  # RightScale ticket #101228-000015
  params[:aliases] = nil if params[:aliases] == "blank"

  Chef::Log.info "Setting up vhost for fqdn (#{fqdn})"

  # Create the sites new home
  directory systemroot do
    mode 0775
    owner "www-data"
    group "www-data"
    recursive true
    action :create
  end

  # Create a directory for extending the vhost config
  directory "/etc/nginx/sites-available/#{fqdn}.d" do
    recursive true
    action :create
  end

  # START - The equivalent of web_app in the apache2 cookbook
  include_recipe "nginx::config_server"

  template "#{node[:nginx][:dir]}/sites-available/#{fqdn}.conf" do
    source params[:template] || "vhost.conf.erb"
    owner "root"
    group "root"
    mode 0644
    if params[:cookbook]
      cookbook params[:cookbook]
    end
    variables(
      :vhost_name => fqdn,
      :params => params
    )
    if ::File.exists?("#{node[:nginx][:dir]}/sites-enabled/#{fqdn}.conf")
      notifies :reload, resources(:service => "nginx"), :delayed
    end
  end

  nginx_site "#{fqdn}.conf" do
    enable enable_setting
  end
  # /END - The equivalent of web_app in the apache2 cookbook

  right_link_tag "nginx::vhost=#{fqdn}"
end