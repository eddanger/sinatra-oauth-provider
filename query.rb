require 'rubygems'
require 'oauth'
require 'oauth/consumer'

require File.dirname(__FILE__) + '/keys.rb'

consumer = OAuth::Consumer.new(Keys::SHARED_KEY, Keys::SHARED_SECRET, {
	:site => 'http://localhost:4567',
	:scheme => :header,
	:http_method => :get,
	:request_token_path => '/oauth/request_token',
	:access_token_path => '/oauth/access_token',
	:authorize_url => '/oauth/authorize'
})

access_token = OAuth::AccessToken.new(consumer, Keys::ACCESS_TOKEN, Keys::ACCESS_SECRET)

puts "Get All Messages"

result = access_token.get "/messages.json"

puts result.body


puts "Get Message 1"

result = access_token.get "/messages/1.json"

puts result.body