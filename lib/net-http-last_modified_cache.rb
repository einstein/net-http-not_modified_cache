require 'active_support/cache'
require 'net/http/last_modified_cache'
require 'rack/utils'

Net::HTTP.send(:include, Net::HTTP::LastModifiedCache)