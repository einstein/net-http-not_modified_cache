require 'net/http'

module Net
  class HTTP
    module LastModifiedCache
      def request_with_last_modified_cache(request, body = nil, &block)
        LastModifiedCache.process_request(request)
        response = request_without_last_modified_cache(request, body, &block)
        LastModifiedCache.process_response(response)
        response
      end

      class << self
        attr_writer :root, :store

        def cacheable_request?(request)
          enabled? && request.is_a?(Get)
        end

        def cacheable_response?(response)
          enabled? && %w(200 304).include?(response.code)
        end

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
            alias_method :request_without_last_modified_cache, :request
            alias_method :request, :request_with_last_modified_cache
          end
        end

        def process_request(request)
          process_request!(request) if cacheable_request?(request)
        end

        def process_response(response)
          process_response!(response) if cacheable_response?(response)
        end

        def root
          @root ||= '/tmp'
        end

        def store
          @store ||= ActiveSupport::Cache.lookup_store(:file_store, root, :compress => true)
        end

        def version
          @version ||= '0.0.0'
        end

        def with_store(store)
          old_store = self.store
          self.store = store
          yield
        ensure
          self.store = old_store
        end

        protected

          def process_request!(request)
          end

          def process_response!(response)
          end
      end

      enable!

      class Entry < Struct.new(:body, :last_modified_at)
      end
    end
  end
end