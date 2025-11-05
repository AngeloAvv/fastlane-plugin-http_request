require 'net/http'
require 'uri'
require 'json'

module Fastlane
  module Helper
    class HttpRequestHelper
      def self.perform_request(uri, method, headers, body, timeout)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.read_timeout = timeout

        request_class = request_class_for(method)
        request = request_class.new(uri.request_uri, headers)

        if body
          request.body = body.to_json
        end

        http.request(request)
      end

      def self.request_class_for(method)
        case method
        when 'GET'    then Net::HTTP::Get
        when 'POST'   then Net::HTTP::Post
        when 'PUT'    then Net::HTTP::Put
        when 'PATCH'  then Net::HTTP::Patch
        when 'DELETE' then Net::HTTP::Delete
        else
          raise ArgumentError, "Unsupported HTTP method: #{method}"
        end
      end
    end
  end
end
