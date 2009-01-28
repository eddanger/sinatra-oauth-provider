require 'rubygems'
require 'oauth'
require 'oauth/consumer'
require 'json'


class OAuthTestWrapper
  API_SERVER = "http://localhost:4567"
  AUTH_SERVER = "http://localhost:4567"
  REQUEST_TOKEN_PATH = "/oauth/request_token"
  ACCESS_TOKEN_PATH  = "/oauth/access_token"
  AUTHORIZATION_URL  = "#{AUTH_SERVER}/oauth/authorize"
  MESSAGES_API_PATH  = "/messages"

  class Error < RuntimeError
  end

  class ArgumentError < Error
  end

  class OAuthTestWrapperException < Error
  end
end

require File.dirname(__FILE__) + '/oauth_test_wrapper/client'
require File.dirname(__FILE__) + '/oauth_test_wrapper/response'
require File.dirname(__FILE__) + '/oauth_test_wrapper/message'
