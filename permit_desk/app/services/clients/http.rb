require 'net/http'
require 'json'

module Clients
  # Thin JSON wrapper over Net::HTTP. Every city service speaks JSON over plain
  # HTTP inside the cluster, so there is nothing cleverer going on here.
  class Http
    OPEN_TIMEOUT = 2
    READ_TIMEOUT = 8
    RETRYABLE = [Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, Errno::ECONNRESET].freeze
    MAX_ATTEMPTS = 3

    def initialize(base_url)
      @base = URI.parse(base_url)
    end

    def get(path, params = {})
      uri = build_uri(path)
      uri.query = URI.encode_www_form(params) if params.any?
      run(Net::HTTP::Get.new(uri))
    end

    def post(path, payload = {})
      request = Net::HTTP::Post.new(build_uri(path))
      request['Content-Type'] = 'application/json'
      request.body = JSON.generate(payload)
      run(request)
    end

    private

    def build_uri(path)
      URI.join("#{@base.scheme}://#{@base.host}:#{@base.port}", path)
    end

    def run(request)
      attempt = 0
      begin
        attempt += 1
        response = dispatch(request)
        if response.code.to_i >= 500
          raise ServiceError.new("#{@base.host} returned #{response.code}", status: response.code.to_i, body: response.body)
        end

        Result.new(response.code.to_i, parse(response.body))
      rescue *RETRYABLE, ServiceError => e
        if attempt < MAX_ATTEMPTS
          sleep(attempt * 1.5)
          retry
        end
        raise e.is_a?(ServiceError) ? e : ServiceError.new(e.message)
      end
    end

    def dispatch(request)
      http = Net::HTTP.new(@base.host, @base.port)
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT
      http.start { |session| session.request(request) }
    end

    def parse(body)
      return {} if body.nil? || body.empty?

      JSON.parse(body)
    rescue JSON::ParserError
      {}
    end

    Result = Struct.new(:status, :body) do
      def ok?
        status < 400
      end
    end
  end
end
