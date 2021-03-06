#
# Cookbook Name:: ruby_enterprise
# Recipe:: default
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Sean Cribbs (<seancribbs@gmail.com>)
# Author:: Michael Hale (<mikehale@gmail.com>)
# Author:: Sasha Gerrand (<sasha@gerrand.net>)
# 
# Copyright:: 2009-2010, Opscode, Inc.
# Copyright:: 2009, Sean Cribbs
# Copyright:: 2009, Michael Hale
# Copyright:: 2010, Sasha Gerrand
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

if ( node[:platform] == 'ubuntu' )
  if ( node[:kernel][:machine] == 'x86_64' )
    kernel_machine = 'amd64'
  else
    kernel_machine = 'i386'
  end

  remote_file "/tmp/ruby-enterprise_#{node[:ruby_enterprise][:version]}_#{kernel_machine}_#{node[:platform]}#{node[:platform_version]}.deb" do
    source "http://rubyforge.org/frs/download.php/71099/ruby-enterprise_#{node[:ruby_enterprise][:version]}_#{kernel_machine}_#{node[:platform]}#{node[:platform_version]}.deb"
  end
   
  bash "Install Ruby Enterprise Edition from deb" do
    cwd "/tmp"
    code <<-EOH
    dpkg -i ruby-enterprise_#{node[:ruby_enterprise][:version]}_#{kernel_machine}_#{node[:platform]}#{node[:platform_version]}.deb
    EOH
  end

  %w{apache2-prefork-dev libapr1-dev libaprutil1-dev}.each do |pkg|
    package pkg
  end

  bash "Install custom Phusion Passenger module" do
    code <<-EOH
    /usr/local/bin/passenger-install-apache2-module --auto
    EOH
  end

else

  include_recipe "build-essential"

  %w{ libssl-dev libreadline5-dev }.each do |pkg|
    package pkg
  end

  remote_file "/tmp/ruby-enterprise-#{node[:ruby_enterprise][:version]}.tar.gz" do
    source "#{node[:ruby_enterprise][:url]}.tar.gz"
    not_if { ::File.exists?("/tmp/ruby-enterprise-#{node[:ruby_enterprise][:version]}.tar.gz") }
  end

  bash "Install Ruby Enterprise Edition" do
    cwd "/tmp"
    code <<-EOH
    tar zxf ruby-enterprise-#{node[:ruby_enterprise][:version]}.tar.gz
    ruby-enterprise-#{node[:ruby_enterprise][:version]}/installer \
      --auto=#{node[:ruby_enterprise][:install_path]} \
      --dont-install-useful-gems
    EOH
    not_if do
      ::File.exists?("#{node[:ruby_enterprise][:install_path]}/bin/ree-version") &&
      system("#{node[:ruby_enterprise][:install_path]}/bin/ree-version | grep -q '#{node[:ruby_enterprise][:version]}$'")
    end
  end

end
