# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/config_file'
require 'faraday'
require 'faraday_middleware'
require 'builder'
require 'rdiscount'

require 'log4r'
include Log4r
logger = Log4r::Logger.new('test')
logger.trace = true
logger.level = DEBUG

formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %t  %M")
Log4r::Logger['test'].outputters << Log4r::Outputter.stdout
Log4r::Logger['test'].outputters << Log4r::FileOutputter.new('logtest', 
                                              :filename =>  'log/app.log',
                                              :formatter => formatter)

logger.info 'got log4r set up'

require_relative 'lib/orcid'

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
  markdown :index, :layout_engine => :erb
end

get '/:id', :provides => ['rss', 'atom', 'xml'] do
  @id = params[:id]
  if params[:id].strip =~ /\A[0-9]{4}\-[0-9]{4}\-[0-9]{4}\-[0-9]{3}[0-9X]\Z/
    builder :rss
  else
    builder :error
  end
end