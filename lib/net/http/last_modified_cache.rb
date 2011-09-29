module Net
  class HTTP
    module LastModifiedCache
      def self.included(base)
        base.class_eval do
          alias_method :request_without_last_modified_cache, :request
          alias_method :request, :request_with_last_modified_cache
        end
      end

      def request_with_last_modified_cache(request, body = nil, &block)
        super
      end
    end
  end
end