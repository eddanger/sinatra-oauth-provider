require 'time'
require 'net/https'
require 'rubygems'
require 'oauth/helper'
require 'oauth/client/helper'
require 'oauth/request_proxy/net_http'
require 'hpricot'

class AttendEase
  API_SERVER = "http://localhost:3000"
  AUTH_SERVER = "http://localhost:3000"
  REQUEST_TOKEN_PATH = "/oauth/request_token"
  ACCESS_TOKEN_PATH  = "/oauth/access_token"
  AUTHORIZATION_URL  = "#{AUTH_SERVER}/oauth/authorize"
  EVENTS_API_PATH    = "/events"
  FORMAT_XML         = "xml"

  class Error < RuntimeError #:nodoc:
  end

  class ArgumentError < Error #:nodoc:
  end

  class AttendEaseException < Error #:nodoc:
  end
end

require File.dirname(__FILE__) + '/attendease/client'
require File.dirname(__FILE__) + '/attendease/response'
require File.dirname(__FILE__) + '/attendease/events'