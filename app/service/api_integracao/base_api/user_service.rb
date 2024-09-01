# Exemplo de serviço específico para uma entidade, como Usuários
module ApiIntegration
  module BaseApi
    class UserService < BaseService
      def create_user(user_params)
        perform_request(endpoint: '/users', method: :post, payload: user_params)
      end

      def update_user(user_id, user_params)
        perform_request(endpoint: "/users/#{user_id}", method: :put, payload: user_params)
      end

      def delete_user(user_id)
        perform_request(endpoint: "/users/#{user_id}", method: :delete)
      end

      def get_user(user_id)
        perform_request(endpoint: "/users/#{user_id}")
      end
    end

  end
end
