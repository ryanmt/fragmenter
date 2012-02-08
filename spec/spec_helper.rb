require 'bundler'

RSpec.configure do |config|
  #config.mock_with :rspec
end


$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'fragmenter'
require 'data'

