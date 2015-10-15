# win_printer

## Description

This LWRP cookbook is designed to support Windows print server management for these functions:

* print queue backups to a file system

This LWRP uses the printbrm.exe utility from MSFT to do the export/import work print server data.

## Sample Usage

### Create a local file system backup of the print server queues and drivers.

    win_printer_backup 'Ensure queue is recently backed up to local file system' do
      action :config # default
      location 'E:\\SystemStateBackup\\PrintQueueBackup.bak' # string
      activity 'export' # string.  default = 'export'
      maxage 16 # integer number of hours.  default = 16
    end

* Please note this location should be included as part of regular file system backups
* backup files older than maxage will trigger a new backup

## WARNING

    Do not use spaces in the filename or file path for your location attribute.  The printbrm.exe utility also cannot tolerate double-quotes around the file path (unlike most MSFT utilities).

	    A regex check has been added to the location attribute that requires all non-whitespace characters in the string, or an error will be raised, thus killing the chef run.

## Author

Dave Viebrock, WSE Team, Nordstrom, Inc.

## License

Copyright (c) 2015 Nordstrom, Inc., All Rights Reserved.
