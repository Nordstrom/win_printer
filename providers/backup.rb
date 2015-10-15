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
    if @current_resource.activity == 'export'
      Chef::Log.info('Chef win_printer_backup found current print server backup - Nothing to do')
    elsif @current_resource.activity == 'import'
      Chef::Log.info('Chef win_printer_backup LWRP succesfully imported print server backup')
    else
      fail 'Chef win_printer_backup LWRP cannot process the supplied activity attribute'
    end
  else
    converge_by("Create #{@new_resource}") do
      export_print_queues
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
