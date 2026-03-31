require 'sinatra'
require 'dotenv/load'
require_relative 'error_handlers'

configure do
  set :show_exceptions, false
  set :dump_errors, false
end

Dir[File.join(__dir__, 'controllers', '**', '*_controller.rb')].sort.each { |file| require file }

# set :public_folder, File.join(__dir__, 'public')
