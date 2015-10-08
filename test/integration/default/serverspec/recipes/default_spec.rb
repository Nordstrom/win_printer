#
# Copyright (c) 2015 Nordstrom, Inc.
#

require 'spec_helper'

describe command('((Get-WmiObject win32_networkadapterconfiguration | ?{$_.IPenabled -eq $true}) | select FullDNSRegistrationEnabled).FullDNSRegistrationEnabled') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^True/) }
end
