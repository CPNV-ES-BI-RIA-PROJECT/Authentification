require 'minitest/test_task'
require_relative 'src/service/api_token_generator_service'
Minitest::TestTask.create

require 'dotenv/load'

task :http do
  sh 'ruby src/http/start.rb'
end

task :lint do
  sh 'rubocop --cache-root .rubocop_cache'
end

task :generate_api_token do
  service = APITokenGeneratorService.new
  puts service.generate_api_token
end
