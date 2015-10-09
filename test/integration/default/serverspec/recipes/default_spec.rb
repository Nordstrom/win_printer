#
# Copyright (c) 2015 Nordstrom, Inc.
#
require 'spec_helper'

describe command('test-path C:\\Windows\\Temp\\PrintQueueBackup.bak') do
  its(:stdout) { should match(/^true/) }
end
