require 'minitest/test_task'
Minitest::TestTask.create

task :http do
  sh 'ruby src/http/start.rb'
end

task :lint do
  sh 'rubocop'
end
