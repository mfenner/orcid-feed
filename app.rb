# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/config_file'
require 'faraday'
require 'faraday_middleware'

require 'log4r'
include Log4r
logger = Log4r::Logger.new('test')
logger.trace = true
logger.level = DEBUG

configure do
  config_file 'config/settings.yml'

  # Set up for http requests to orcid.org public API
  pub_orcid_org = Faraday.new(:url => 'http://pub.orcid.org') do |c|
    c.use FaradayMiddleware::FollowRedirects, :limit => 5
    c.adapter :net_http
  end

  set :pub_orcid_org, pub_orcid_org
end

get '/' do
  "Hello world"
end