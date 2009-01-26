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

request_token = consumer.get_request_token

puts "Request Token and Secret: " + request_token.token + " " + request_token.secret

puts "Authorization URL: http://localhost:4567" + request_token.authorize_url