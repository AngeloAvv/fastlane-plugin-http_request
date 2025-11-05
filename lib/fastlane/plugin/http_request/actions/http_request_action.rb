require 'fastlane/action'
require 'fastlane_core/configuration/config_item'
require 'fastlane_core/ui/ui'
require 'json'
require_relative '../helper/http_request_helper'

UI = FastlaneCore::UI unless defined?(UI)

module Fastlane
  module Actions
    class HttpRequestAction < Action
      def self.run(params)
        uri = URI.parse(params[:url])
        method = params[:method].to_s.upcase
        headers = params[:headers] || {}
        body = params[:body]
        timeout = params[:timeout] || 30
        verbose = params[:verbose] || false

        UI.message("➡️  Sending HTTP #{method} request to #{uri}")

        response = Helper::HttpRequestHelper.perform_request(uri, method, headers, body, timeout)

        handle_response(response, verbose)
      rescue StandardError => e
        UI.user_error!("HTTP request failed: #{e.message}")
      end

      def self.handle_response(response, verbose)
        UI.success("✅ HTTP #{response.code} #{response.message}")
        UI.message("Response body: #{response.body[0..500]}") if verbose && response.body

        raw_body = response.body || ""

        parsed_body = begin
          JSON.parse(raw_body)
        rescue JSON::ParserError
          raw_body
        end

        {
          code: response.code.to_i,
          body: parsed_body,
          headers: response.each_header.to_h
        }
      end

      # Plugin description
      def self.description
        "Fastlane plugin to send HTTP requests (GET, POST, PUT, DELETE, etc.)"
      end

      # Optional detailed description
      def self.details
        "A general-purpose HTTP request action for Fastlane, allowing you to call APIs or webhooks from your lanes."
      end

      def self.authors
        ["Angelo Cassano"]
      end

      def self.return_value
        "A hash containing :code (Integer), :body (Hash or String), and :headers (Hash) from the HTTP response."
      end

      # Configurable parameters for the action
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :url,
            env_name: "HTTP_REQUEST_URL",
            description: "The target URL for the HTTP request",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :method,
            env_name: "HTTP_REQUEST_METHOD",
            description: "HTTP method to use (GET, POST, PUT, PATCH, DELETE)",
            optional: true,
            default_value: "GET",
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :headers,
            env_name: "HTTP_REQUEST_HEADERS",
            description: "Optional HTTP headers as a Ruby hash",
            optional: true,
            type: Hash
          ),
          FastlaneCore::ConfigItem.new(
            key: :body,
            env_name: "HTTP_REQUEST_BODY",
            description: "Optional HTTP request body (Hash or String)",
            optional: true,
            type: Hash
          ),
          FastlaneCore::ConfigItem.new(
            key: :timeout,
            env_name: "HTTP_REQUEST_TIMEOUT",
            description: "Request timeout in seconds",
            optional: true,
            default_value: 30,
            type: Integer
          ),
          FastlaneCore::ConfigItem.new(
            key: :verbose,
            env_name: "HTTP_REQUEST_VERBOSE",
            description: "If true, prints response body to logs",
            optional: true,
            default_value: false,
            type: Boolean
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
