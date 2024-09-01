require 'net/http'
require 'uri'
require 'json'

module ApiIntegration
  module BaseApi
    class BaseService
      def initialize(token = nil)
        @token = token || ENV['API_TOKEN']
      end

      # Define o host da API (produção e homologação)
      def host
        Rails.env.production? ? 'https://api.production.com/v1' : 'https://sandbox.api.com/v1'
      end

      # Método genérico para realizar uma requisição à API
      def perform_request(endpoint:, method: :get, payload: {}, headers: {})
        uri = URI.parse("#{host}#{endpoint}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")

        # Escolhe o tipo de requisição baseado no método passado (:get, :post, etc.)
        request = build_request(method, uri, headers)
        request.body = payload.to_json unless payload.empty?

        # Executa a requisição e trata a resposta
        response = http.request(request)
        parse_response(response)
      end

      private

      # Constrói a requisição HTTP de acordo com o método escolhido
      def build_request(method, uri, headers)
        request_class = case method
                        when :post then Net::HTTP::Post
                        when :put then Net::HTTP::Put
                        when :delete then Net::HTTP::Delete
                        else Net::HTTP::Get
                        end
        request = request_class.new(uri)
        request["Authorization"] = "Bearer #{@token}" if @token
        request["Content-Type"] = "application/json"
        headers.each { |key, value| request[key] = value }
        request
      end

      # Analisa a resposta da API
      def parse_response(response)
        case response.code.to_i
        when 200, 201
          { success: true, data: JSON.parse(response.body) }
        else
          { success: false, error: response.message, details: response.body }
        end
      end
    end
  end
end
