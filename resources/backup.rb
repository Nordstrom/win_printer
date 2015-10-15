# Encoding: utf-8

actions :config
default_action :config

attribute :location, kind_of: String, required: true, regex: [/^\S*$/]
attribute :maxage, kind_of: Integer, default: 16
attribute :activity, kind_of: String, required: true, default: 'export', equal_to: %w(export import)
attr_accessor :exists
