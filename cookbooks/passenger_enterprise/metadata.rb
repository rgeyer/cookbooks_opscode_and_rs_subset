maintainer       "Opscode, Inc."
maintainer_email "ops@opscode.com"
license          "Apache 2.0"
description      "Installs and configures Passenger under Ruby Enterprise Edition with Apache"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.4.2"

recipe "passenger_enterprise", "Installs Passenger gem with Ruby Enterprise Edition"
recipe "passenger_enterprise::apache2", "Enables Apache module configuration for passenger under Ruby Enterprise Edition"
recipe "passenger_enterprise::nginx", "Installs Passenger gem w/ REE, and recompiles support into Nginx"

%w{ ruby_enterprise nginx apache2 }.each do |cb|
  depends cb
end

supports "ubuntu"

attribute "nginx/dir",
  :display_name => "Nginx Directory",
  :description => "Location of nginx configuration files",
  :default => "/etc/nginx",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/content_dir",
  :display_name => "Nginx Content Directory",
  :description => "Location of nginx content files",
  :default => "/var/www",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/log_dir",
  :display_name => "Nginx Log Directory",
  :description => "Location for nginx logs",
  :default => "/var/log/nginx",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/user",
  :display_name => "Nginx User",
  :description => "User nginx will run as",
  :default => "www-data",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/binary",
  :display_name => "Nginx Binary",
  :description => "Location of the nginx server binary",
  :default => "/usr/sbin/nginx",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/gzip",
  :display_name => "Nginx Gzip",
  :description => "Whether gzip is enabled",
  :default => "on",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/gzip_http_version",
  :display_name => "Nginx Gzip HTTP Version",
  :description => "Version of HTTP Gzip",
  :default => "1.0",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/gzip_comp_level",
  :display_name => "Nginx Gzip Compression Level",
  :description => "Amount of compression to use",
  :default => "2",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/gzip_proxied",
  :display_name => "Nginx Gzip Proxied",
  :description => "Whether gzip is proxied",
  :default => "any",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/gzip_types",
  :display_name => "Nginx Gzip Types",
  :description => "Supported MIME-types for gzip",
  :type => "array",
  :default => [ "text/plain", "text/html", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript" ],
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/keepalive",
  :display_name => "Nginx Keepalive",
  :description => "Whether to enable keepalive",
  :default => "on",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/keepalive_timeout",
  :display_name => "Nginx Keepalive Timeout",
  :default => "65",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/worker_processes",
  :display_name => "Nginx Worker Processes",
  :description => "Number of worker processes",
  :default => "1",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/worker_connections",
  :display_name => "Nginx Worker Connections",
  :description => "Number of connections per worker",
  :default => "1024",
  :recipes => ["passenger_enterprise::nginx"]

attribute "nginx/server_names_hash_bucket_size",
  :display_name => "Nginx Server Names Hash Bucket Size",
  :default => "64",
  :recipes => ["passenger_enterprise::nginx"]