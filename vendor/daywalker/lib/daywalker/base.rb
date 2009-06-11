module Daywalker
  class Base # :nodoc:
    include HTTParty
    base_uri 'http://services.sunlightlabs.com/api'

    protected

    def self.handle_response(response)
      case response.code.to_i
      when 403 then raise BadApiKeyError
      when 200
        begin
          parse(response.body)
        rescue => e
          raise "Error while parsing #{response.body.inspect} => #{e.inspect}"
        end

      when 400 then handle_bad_request(response.body)
      else          raise "Don't know how to handle code #{response.code.inspect}"
      end
    end

    def self.handle_bad_request(body)
      case body
      when "No Such Object Exists" then raise NotFoundError
      else raise "Don't know how to handle #{body.inspect}"
      end
    end
  end
end
