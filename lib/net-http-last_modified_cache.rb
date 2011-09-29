require 'active_support'
require 'net/http'
require 'net/http/last_modified_cache'
require 'net/http/last_modified_cache/version'

Net::HTTP.send(:include, Net::HTTP::LastModifiedCache)