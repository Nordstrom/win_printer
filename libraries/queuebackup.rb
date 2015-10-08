# Encoding: utf-8

module Windows
  # helpers for the dhcp_server backup LWRP
  module Printerqueuebackup
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
      maxage_seconds = maxage * 3600
      if ::File.exist?(location)
        filemodtime = ::File.mtime(location)
      else
        filemodtime = Time.now
      end
      now = Time.now
      # max age of file before another backup is 16 hours
      cutofftime = now - maxage_seconds
      filemodtime < cutofftime
    end

    def export_print_queues
      location = new_resource.location
      dhcpexportcmd = shell_out!(" #{location} ")
      Chef::Log.info("win_printer_queuebackup LWRP successfully exported print queues to #{location}...")
      dhcpexportcmd.stderr.empty? && dhcpexportcmd.stdout.include?('Command completed successfully')
    end

    def import_printqueue_backup
      location = new_resource.location
      queuebackupexist = ::File.exist?(location)
      fail("No print queue backup exists in #{location} to use for win_printer_queuebackup import activity") unless queuebackupexist
      queueimportcmd = shell_out!(" #{location} ")
      queueimportcmd.stderr.empty? && queueimportcmd.stdout.include?('Command completed successfully')
    end
  end
end
