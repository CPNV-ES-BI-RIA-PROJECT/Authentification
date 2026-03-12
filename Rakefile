require 'minitest/test_task'
Minitest::TestTask.create

require 'dotenv/load'

task :http do
  sh 'ruby src/http/start.rb'
end

task :lint do
  sh 'rubocop --cache-root .rubocop_cache'
end
