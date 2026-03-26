require 'json'
require_relative '../config'

get '/api/docs' do
  content_type :html

  <<~HTML
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Authentication API Docs</title>
        <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
        <style>
          body { margin: 0; background: #fafafa; }
          #swagger-ui { max-width: 1200px; margin: 0 auto; }
        </style>
      </head>
      <body>
        <div id="swagger-ui"></div>
        <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
        <script>
          window.ui = SwaggerUIBundle({
            url: "/api/docs/openapi.json",
            dom_id: "#swagger-ui",
            deepLinking: true,
            layout: "BaseLayout"
          });
        </script>
      </body>
    </html>
  HTML
end

get '/api/docs/openapi.json' do
  content_type :json
  openapi_spec.to_json
end

def openapi_spec
  {
    openapi: '3.0.3',
    info: openapi_info,
    servers: [{ url: request.base_url.to_s }],
    tags: [{ name: 'Health' }, { name: 'Sessions' }],
    paths: openapi_paths,
    components: openapi_components
  }
end

def openapi_info
  {
    title: 'Authentication API',
    version: API_VERSION,
    description: 'Endpoints for health checks, login, session inspection and logout.'
  }
end

def openapi_paths
  {
    "#{PREFIX}health" => {
      get: openapi_get_health
    },
    "#{PREFIX}sessions" => {
      get: openapi_get_session,
      post: openapi_create_session,
      delete: openapi_delete_session
    }
  }
end

def openapi_get_health
  {
    tags: ['Health'],
    summary: 'Health check',
    description: 'Returns the API health status and version.',
    responses: {
      '200' => json_response('Health status', '#/components/schemas/HealthResponse')
    }
  }
end

def openapi_get_session
  {
    tags: ['Sessions'],
    summary: 'Get current session',
    description: 'Returns the current authenticated user from the bearer token.',
    security: [{ bearerAuth: [] }],
    responses: {
      '200' => json_response('Current user payload', '#/components/schemas/CurrentSession'),
      '401' => json_response('Unauthorized', '#/components/schemas/ErrorResponse')
    }
  }
end

def openapi_create_session
  {
    tags: ['Sessions'],
    summary: 'Create session (login)',
    description: 'Authenticates a user and returns a bearer token.',
    requestBody: {
      required: true,
      content: {
        'application/x-www-form-urlencoded' => {
          schema: { '$ref' => '#/components/schemas/LoginRequest' }
        }
      }
    },
    responses: {
      '200' => json_response('Session token', '#/components/schemas/LoginResponse'),
      '400' => json_response('Bad request', '#/components/schemas/ErrorResponse'),
      '401' => json_response('Unauthorized', '#/components/schemas/ErrorResponse')
    }
  }
end

def openapi_delete_session
  {
    tags: ['Sessions'],
    summary: 'Delete session (logout)',
    description: 'Revokes the current bearer token.',
    security: [{ bearerAuth: [] }],
    responses: {
      '200' => { description: 'Logout succeeded' },
      '401' => json_response('Unauthorized', '#/components/schemas/ErrorResponse')
    }
  }
end

def openapi_components
  {
    securitySchemes: openapi_security_schemes,
    schemas: openapi_schemas
  }
end

def openapi_security_schemes
  {
    bearerAuth: {
      type: 'http',
      scheme: 'bearer',
      bearerFormat: 'JWT'
    }
  }
end

def openapi_schemas
  {
    HealthResponse: health_response_schema,
    LoginRequest: login_request_schema,
    LoginResponse: login_response_schema,
    CurrentSession: current_session_schema,
    ErrorResponse: error_response_schema
  }
end

def health_response_schema
  {
    type: 'object',
    required: %w[status version],
    properties: {
      status: { type: 'string', example: 'ok' },
      version: { type: 'string', example: API_VERSION }
    }
  }
end

def login_request_schema
  {
    type: 'object',
    required: %w[username password],
    properties: {
      username: { type: 'string', example: 'alice' },
      password: { type: 'string', example: 'secret' }
    }
  }
end

def login_response_schema
  {
    type: 'object',
    required: ['token'],
    properties: {
      token: { type: 'string', example: 'Bearer eyJhbGciOi...' }
    }
  }
end

def current_session_schema
  {
    type: 'object',
    properties: {
      username: { type: 'string', example: 'alice' },
      provider: { type: 'string', example: 'fake' }
    },
    additionalProperties: true
  }
end

def error_response_schema
  {
    type: 'object',
    required: ['error'],
    properties: {
      error: { type: 'string', example: 'Invalid token' }
    }
  }
end

def json_response(description, schema_ref)
  {
    description: description,
    content: {
      'application/json' => {
        schema: { '$ref' => schema_ref }
      }
    }
  }
end
