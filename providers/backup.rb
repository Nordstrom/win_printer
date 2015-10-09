# Encoding: utf-8
# Author:: Dave Viebrock (<dave.viebrock@nordstrom.com>)
# Cookbook Name:: win_printer
# Provider:: queuebackup
#

include Chef::Mixin::ShellOut
include Chef::Mixin::PowershellOut
include Windows::Printerbackup

# Support whyrun
def whyrun_supported?
  true
end

use_inline_resources

action :config do
  if @current_resource.exists
    Chef::Log.info('Chef dhcp_server_backup found current DHCP backup - Nothing to do')
  else
    converge_by("Create #{@new_resource}") do
      export_print_queues
      new_resource.updated_by_last_action true
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::WinPrinterBackup.new(@new_resource.name)
  @current_resource.location(@new_resource.location)
  @current_resource.activity(@new_resource.activity)
  @current_resource.maxage(@new_resource.maxage)
  @current_resource.exists = config_exists(@current_resource.name)
end
