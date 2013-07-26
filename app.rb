# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/config_file'
require 'faraday'
require 'faraday_middleware'
require 'builder'
require 'rdiscount'
require 'json'

configure do
  config_file 'config/settings.yml'

  #set :environment, :development
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  markdown :index, :layout_engine => :erb, :escape_html => false
end

get '/:id', :provides => ['rss', 'atom', 'xml'] do
  @id = params[:id]
  if is_orcid?(@id)
  	profile = get_profile(@id)
  	if profile
  	  @title = [profile['personal-details']['given-names']['value'], profile['personal-details']['family-name']['value']].join(" ")
  	  @description = profile['biography'] ? profile['biography']['value'] : nil 
      builder :rss
  	else
      builder :error
  	end
  else
    builder :error
  end
end

def is_orcid?(string)
  string.strip =~ /\A[0-9]{4}\-[0-9]{4}\-[0-9]{4}\-[0-9]{3}[0-9X]\Z/
end

def get_profile(id)
  conn = Faraday.new(:url => 'http://pub.orcid.org') do |c|
  	c.request :json
  	c.response :json, :content_type => /\bjson$/
    c.adapter Faraday.default_adapter
  end

  response = conn.get do |r|
    r.url "#{id}/orcid-bio"
    r.headers['Accept'] = 'application/json'
  end

  if response.status == 200
  	bio = response.body['orcid-profile']['orcid-bio']
  else
  	nil
  end
end