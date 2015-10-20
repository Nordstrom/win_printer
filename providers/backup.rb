# Encoding: utf-8
# Copyright 2015 Nordstrom, Inc.
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
