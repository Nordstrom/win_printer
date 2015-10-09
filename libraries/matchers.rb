if defined?(ChefSpec)
  def config_win_printer_backup(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:win_printer_backup, 'config', resource_name)
  end
end
