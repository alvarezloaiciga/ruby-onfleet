require 'faraday'

class Onfleet
  def self.validate_authentication(base_url, api_key)
    body = nil
    headers = nil
    method = 'get'.to_sym
    success = false
    request = Faraday.new
    url = "#{base_url}/auth/test"

    begin
      request.set_basic_auth(api_key, api_key)
      response = request.run_request(method, url, body, headers)
      handle_api_error(response)

      if response.status == 200
        success = true
      end
    rescue Faraday::Response::RaiseError => e
      raise HttpError, "Received the following error when running auth test: #{e}"
    end
    success
  end

  def self.handle_api_error(response)
    if response.status == 401 || response.status == 403
      raise PermissionError, "status: #{response.status}, message: #{response.body}"
    elsif response.status >= 400 && response.status < 500
      raise HttpError, "status: #{response.status}, message: #{response.body}"
    elsif response.status >= 500
      raise ServiceError, "status: #{response.status}, message: #{response.body}"
    end
  end
end