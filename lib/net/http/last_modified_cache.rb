module Net
  class HTTP
    module LastModifiedCache
      class << self
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
      end

      enable!

      def request_with_last_modified_cache(request, body = nil, &block)
        request_without_last_modified_cache(request, body, &block)
      end
    end
  end
end