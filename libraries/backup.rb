# Encoding: utf-8

module Windows
  # helpers for the dhcp_server backup LWRP
  module Printerbackup
    def config_exists(*)
      activity = new_resource.activity
      Chef::Log.info('Checking for current print server backup status')
      if activity.eql?('export')
        current_printqueue_backup == true
      elsif activity.eql?('import')
        import_printqueue_backup
      end
    end

    def current_printqueue_backup
      location = new_resource.location
      maxage = new_resource.maxage
      # force maxage to 1 if a zero value is supplied
      maxage = 1 if maxage <= 0
      maxage_seconds = maxage * 3600
      if ::File.file?(location)
        filemodtime = ::File.mtime(location)
        Chef::Log.info("win_printer_backup found file modification time #{filemodtime}")
      else
        filemodtime = Time.now - 86_400
        Chef::Log.info("win_printer_backup found no file, set modification time as #{filemodtime}")
      end
      now = Time.now
      # max age of file before another backup is 16 hours
      cutofftime = now - maxage_seconds
      Chef::Log.info("win_printer_backup file age cutoff time #{cutofftime}")
      Chef::Log.info("win_printer_backup current file test comparison result: #{filemodtime > cutofftime}")
      Chef::Log.info("win_printer_backup current file age comparison result: #{filemodtime - cutofftime} seconds")
      filemodtime > cutofftime
    end

    def export_print_queues
      location = new_resource.location
      # ensure old file doesn't exist, otherwise printbrm.exe will fail
      ::File.delete(location) if ::File.file?(location)
      # export the printer queues to the file
      exportcmd = shell_out("C:\\Windows\\System32\\spool\\tools\\printbrm.exe -B -S \\\\%computername% -F #{location}", returns: [0])
      Chef::Log.info("win_printer_backup LWRP backup location: #{location}")
      Chef::Log.info("win_printer_backup LWRP backup result: #{exportcmd.stdout}")
      exportcmd.stderr.empty? && exportcmd.stdout.include?('Successfully finished operation')
    end

    def import_printqueue_backup
      location = new_resource.location
      backupexist = ::File.file?(location)
      fail("No print queue backup exists in #{location} to use for win_printer_queuebackup import activity") unless backupexist
      importcmd = shell_out!("C:\\Windows\\System32\\spool\\tools\\printbrm.exe -R -S \\\\%computername% -F #{location} -O force -P all", returns: [0])
      Chef::Log.info("win_printer_backup LWRP import location: #{location}")
      Chef::Log.info("win_printer_backup LWRP import result: #{importcmd.stdout}")
      importcmd.stderr.empty? && importcmd.stdout.include?('Successfully finished operation')
    end
  end
end
