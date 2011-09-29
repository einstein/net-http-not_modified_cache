require 'net/http'
require 'net/http/last_modified_cache'

Net::HTTP::Request.send(:include, Net::HTTP::LastModifiedCache)