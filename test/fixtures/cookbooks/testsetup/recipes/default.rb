win_printer_backup 'Ensure local print queue backup file exists' do
  action :config
  location 'C:\\Windows\\Temp\\PrintQueueBackup.bak'
  maxage 1
  activity 'export'
end
