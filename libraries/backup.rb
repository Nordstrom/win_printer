# Encoding: utf-8

module Windows
  # helpers for the dhcp_server backup LWRP
  module Printerbackup
    def config_exists(*)
      activity = new_resource.activity
      Chef::Log.info('Checking for current print server backup status')
      if activity.eql?('export')
        current_printqueue_backup
        Chef::Log.info('Chef detected current print queue backup')
      elsif activity.eql?('import')
        import_printqueue_backup
        Chef::Log.info('Chef completed print server backup to filesystem')
      end
    end

    def current_printqueue_backup
      location = new_resource.location
      maxage = new_resource.maxage
      # force maxage to 1 if a zero value is supplied
      maxage = 1 if maxage == 0
      maxage_seconds = maxage * 3600
      if ::File.exist?(location)
        filemodtime = ::File.mtime(location)
        Chef::Log.info("win_printer_backup found file modification time #{filemodtime}")
      else
        filemodtime = Time.now
        Chef::Log.info("win_printer_backup found no file, set modification time as #{filemodtime}")
      end
      now = Time.now
      # max age of file before another backup is 16 hours
      cutofftime = now - maxage_seconds
      Chef::Log.info("win_printer_backup file age cutoff time #{cutofftime}")
      Chef::Log.info("win_printer_backup file comparison result: #{filemodtime < cutofftime}")
      filemodtime < cutofftime
    end

    def export_print_queues
      location = new_resource.location
      # ensure old file doesn't exist, otherwise printbrm.exe will fail
      begin
        File.delete(location) if File.exist?(location)
      rescue Errno::ENOENT
        raise("win_printer_queuebackup LWRP failed to delete pre-existing backup file: #{location}...")
      end
      # export the printer queues to the file
      queueexportcmd = shell_out!("printbrm -B -S %computername% -F \"#{location}\" -O force")
      Chef::Log.info("win_printer_queuebackup LWRP successfully exported print queues to #{location}...")
      queueexportcmd.stderr.empty? && queueexportcmd.stdout.include?('Successfully finished operation')
    end

    def import_printqueue_backup
      location = new_resource.location
      queuebackupexist = ::File.exist?(location)
      fail("No print queue backup exists in #{location} to use for win_printer_queuebackup import activity") unless queuebackupexist
      queueimportcmd = shell_out!("printbrm -R -S %computername% -F #{location} -O force -P all")
      queueimportcmd.stderr.empty? && queueimportcmd.stdout.include?('Successfully finished operation')
    end
  end
end
