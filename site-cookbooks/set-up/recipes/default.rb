#
# Cookbook Name:: set-up
# Recipe:: default
#
# Copyright 2014, HAKOPAKO
#
# All rights reserved - Do Not Redistribute
#

### epel remi
package "yum" do
	action :upgrade
end

remote_file "#{Chef::Config[:file_cache_path]}/epel-release-6-8.noarch.rpm" do
	source "http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
	not_if "rpm -qa | grep -q '^epel-release'"
	action :create
	notifies :install, "rpm_package[epel-release]", :immediately
end

rpm_package "epel-release" do
	source "#{Chef::Config[:file_cache_path]}/epel-release-6-8.noarch.rpm"
	action :nothing
end

remote_file "#{Chef::Config[:file_cache_path]}/remi-release-6.rpm" do
	source "http://rpms.famillecollet.com/enterprise/remi-release-6.rpm"
	not_if "rpm -qa | grep -q '^remi-release'"
	action :create
	notifies :install, "rpm_package[remi-release]", :immediately
end

rpm_package "remi-release" do
	source "#{Chef::Config[:file_cache_path]}/remi-release-6.rpm"
	action :nothing
end

template "remi.repo" do
	path "/etc/yum.repos.d/remi.repo"
	source "remi.repo.erb"
	mode 0644
end

##################################################################
### install
##################################################################
%w{
	httpd 
	httpd-devel 
	mysql-server 
	php-mysql 
	memcached 
	php-pecl-memcache 
	php-dom 
	subversion 
	git-core 
	vim-enhanced 
	php 
	php-devel 
	php-mbstring 
	php-mcrypt 
	php-pear 
}.each do |p|	
	package p do
		action :install
		options "--enablerepo=remi --enablerepo=remi-php55"
	end
end

bash "upgrade_pear" do
	user "root"
	code <<-EOH
		pear channel-discover pear.phpunit.de
		pear channel-update pear.php.net
		pear channel-discover components.ez.no  
		pear upgrade pear  
	EOH
end

bash "install_HTTP_Request2" do
	user "root"
	code "pear install HTTP_Request2"
	not_if { ::File.exists?("/usr/share/pear/HTTP/Request2.php")}
end

bash "install_xml_serializer" do
	user "root"
	code "pear install --alldeps xml_serializer-beta"
	not_if { ::File.exists?("/usr/share/pear/XML/Serializer.php")}
end

bash "install_phpunit" do
	user "root"
	code <<-EOH 
		pear install -o pear.phpunit.de/PHPUnit 
		pear install phpunit/PHP_CodeCoverage
	EOH
	not_if { ::File.exists?("/usr/bin/phpunit")}
end

bash "install_jenkins" do
	user "root"
	code <<-EOH
		yum -y install java-1.7.0-openjdk.x86_64
		wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo 
		rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
		yum -y install jenkins
	EOH
	not_if { ::File.exists?("/usr/bin/jenkins")}
end

##################################################################
### services
##################################################################
service "iptables" do
	supports :status => true, :restart => true, :reload => true
	action [:enable, :start]
end
service "httpd" do
	supports :status => true, :restart => true, :reload => true
	action [:enable, :start]
end

##################################################################
### templates
##################################################################
template "php.ini" do
	path "/etc/php.ini"
	source "php.ini.erb"
	mode 0644
end

template "httpd.conf" do
	path "/etc/httpd/conf/httpd.conf"
	source "httpd.conf.erb"
	mode 0644
	notifies :start, 'service[httpd]'
end

template "iptables" do
	path "etc/sysconfig/iptables"
	source "iptables"
	owner "root"
	group "root"
	mode 0600
	notifies :restart, 'service[iptables]'
end

##################################################################
### Other services
##################################################################
service "mysqld" do
	supports :status => true, :restart => true, :reload => true
	action [:enable, :start]
end

service "memcached" do
	supports :status => true, :restart => true, :reload => true
	action [:enable, :start]
end

service "jenkins" do
	supports :status => true, :restart => true, :reload => true
	action [:enable, :start]
end


