require 'active_support/cache'
require 'net/http'
require 'rack/utils'
require 'time'

module Net
  class HTTP
    module NotModifiedCache
      def cache_entry(response)
        last_modified_at = Time.parse(response['last-modified'] || response['date']) rescue Time.now
        Entry.new(response.body, response['etag'], last_modified_at)
      end

      def cache_key(request)
        [address, request.path].join
      end

      def cache_request(request, key)
        cache_request!(request, key) if cacheable_request?(request)
      end

      def cache_request!(request, key)
      end

      def cacheable_request?(request)
        NotModifiedCache.enabled? && request.is_a?(Get)
      end

      def cache_response(response, key)
        cache_response!(response, key) if cacheable_response?(response)
      end

      def cache_response!(response, key)
      end

      def cacheable_response?(response)
        NotModifiedCache.enabled? && %w(200 304).include?(response.code)
      end

      def request_with_not_modified_cache(request, body = nil, &block)
        key = cache_key(request)
        cache_request(request, key)
        response = request_without_not_modified_cache(request, body, &block)
        cache_response(response, key)
        response
      end

      class << self
        attr_writer :root, :store

        def disable!
          @enabled = false
        end

        def enable!
          @enabled = true
        end

        def enabled?
          @enabled
        end

        def included(base)
          base.class_eval do
            alias_method :request_without_not_modified_cache, :request
            alias_method :request, :request_with_not_modified_cache
          end
        end

        def root
          @root ||= '/tmp/net-http-not_modified_cache'
        end

        def store
          @store ||= ActiveSupport::Cache.lookup_store(:file_store, root, :compress => true)
        end

        def version
          @version ||= '0.0.0'
        end

        def while_disabled(&block)
          while_enabled_is(false, &block)
        end

        def while_enabled(&block)
          while_enabled_is(true, &block)
        end

        def while_enabled_is(boolean)
          old_enabled = @enabled
          @enabled = boolean
          yield
        ensure
          @enabled = old_enabled
        end

        def with_store(store)
          old_store = self.store
          self.store = store
          yield
        ensure
          self.store = old_store
        end
      end

      enable!

      class Entry < Struct.new(:body, :etag, :last_modified_at)
      end
    end
  end
end

Net::HTTP.send(:include, Net::HTTP::NotModifiedCache)