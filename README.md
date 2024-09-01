## Integração com APIs
![Ruby Logo](https://upload.wikimedia.org/wikipedia/commons/7/73/Ruby_logo.svg)
![Ruby on Rails Logo](https://upload.wikimedia.org/wikipedia/commons/6/62/Ruby_On_Rails_Logo.svg)

Este projeto inclui uma estrutura modular para integrar com diferentes APIs de maneira eficiente e reutilizável. A seguir, detalhamos como essa estrutura foi implementada e como você pode utilizá-la para integrar com qualquer API.

### Estrutura Geral

A integração com APIs é gerenciada através de serviços Ruby, organizados da seguinte maneira:

- **Classe Base (`BaseService`)**: Contém a lógica comum para lidar com requisições HTTP, incluindo configuração de hosts, headers, e análise de respostas.
- **Classes Específicas**: Cada classe específica herda da `BaseService` e implementa métodos para interagir com endpoints específicos da API.

## Explicação do Código

### Estrutura Geral

Este projeto utiliza uma estrutura modular para integração com APIs, organizada em uma classe base (`BaseService`) que gerencia a lógica comum de requisições HTTP e classes específicas que herdam da classe base para interagir com endpoints específicos da API.

### `BaseService`

A classe `BaseService` é responsável por definir os métodos essenciais para a integração com APIs.
```ruby
#### `initialize(token = nil)`

def initialize(token = nil)
  @token = token || ENV['API_TOKEN']
end

Objetivo: Inicializa a classe com um token de autenticação. Se nenhum token for fornecido, ele utiliza um
token padrão definido na variável de ambiente API_TOKEN.
```
`host`

````ruby
def host
  Rails.env.production? ? 'https://api.production.com/v1' : 'https://sandbox.api.com/v1'
end

Objetivo: Define a URL base da API. A URL muda de acordo com o ambiente (produção ou desenvolvimento/sandbox).
````

`perform_request(endpoint:, method: :get, payload: {}, headers: {})`
````ruby

def perform_request(endpoint:, method: :get, payload: {}, headers: {})
  uri = URI.parse("#{host}#{endpoint}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")

  request = build_request(method, uri, headers)
  request.body = payload.to_json unless payload.empty?

  response = http.request(request)
  parse_response(response)
end

. Objetivo: Método principal para realizar requisições HTTP.
. endpoint: O caminho na API para o qual a requisição será enviada.
. method: O método HTTP (GET, POST, PUT, DELETE).
. payload: Os dados que serão enviados no corpo da requisição.
. headers: Headers adicionais para a requisição.
````

`build_request(method, uri, headers)`
````ruby
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

. Objetivo: Cria a requisição HTTP apropriada com base no método especificado.
. Define o tipo de requisição HTTP (GET, POST, PUT, DELETE).
. Adiciona o token de autorização, se disponível.
. Configura os headers.
````

`parse_response(response)`
````ruby
def parse_response(response)
  case response.code.to_i
  when 200, 201
    { success: true, data: JSON.parse(response.body) }
  else
    { success: false, error: response.message, details: response.body }
  end
end

. Objetivo: Interpreta a resposta da API.
. Se o código de status for 200 ou 201, considera a resposta bem-sucedida e parseia os dados do JSON.
. Para outros códigos, retorna uma mensagem de erro junto com os detalhes.
````

- **UserService**:

A classe UserService herda de BaseService e implementa métodos específicos para interagir com a API de usuários.
`create_user(user_params)`
````ruby
def create_user(user_params)
  perform_request(endpoint: '/users', method: :post, payload: user_params)
end
. Objetivo: Envia uma requisição POST para criar um novo usuário.
````

`update_user(user_id, user_params)`
````ruby
def update_user(user_id, user_params)
  perform_request(endpoint: "/users/#{user_id}", method: :put, payload: user_params)
end
. Objetivo: Envia uma requisição PUT para atualizar os dados de um usuário existente.
````

`delete_user(user_id)`
````ruby
def delete_user(user_id)
  perform_request(endpoint: "/users/#{user_id}", method: :delete)
end
. Objetivo: Envia uma requisição DELETE para remover um usuário específico.
````

`get_user(user_id)`
````ruby
def get_user(user_id)
  perform_request(endpoint: "/users/#{user_id}")
end
. Objetivo: Envia uma requisição GET para buscar os dados de um usuário específico.
````
````ruby
Exemplo:

module ApiIntegration
  class OrderService < BaseService
    def create_order(order_params)
      perform_request(endpoint: '/orders', method: :post, payload: order_params)
    end

    def get_order(order_id)
      perform_request(endpoint: "/orders/#{order_id}")
    end
  end
end
````

## Conclusão

Este padrão de integração facilita o desenvolvimento de serviços para qualquer API, promovendo a reutilização
de código e a manutenção simplificada. Siga esta estrutura ao adicionar novos endpoints ou ao integrar com APIs
diferentes, garantindo consistência e eficiência no seu código.
