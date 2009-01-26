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

request_token = OAuth::RequestToken.new(consumer, Keys::REQUEST_TOKEN, Keys::REQUEST_SECRET)

access_token = request_token.get_access_token

puts "Access Token and Secret: " + access_token.token + " " + access_token.secret