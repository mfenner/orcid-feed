# -*- coding: utf-8 -*-

require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/respond_to'
require 'faraday'
require 'faraday_middleware'
require 'builder'
require 'rdiscount'
require 'bibtex'
require 'rdf'
require 'citeproc'
require 'multi_json'

Sinatra::Application.register Sinatra::RespondTo

require_relative 'lib/helpers'
require_relative 'lib/profile'
require_relative 'lib/work'

configure do
  config_file 'config/settings.yml'

  set :environment, :development

  mime_type :bib, 'application/x-bibtex'
end

get '/' do
  markdown :index, :layout_engine => :erb
end

get '/:orcid' do
  redirect '/' unless is_orcid?(params[:orcid])

  @profile = Profile.new(params[:orcid])

  respond_to do |format|
    format.html do
      redirect "http://orcid.org/#{params[:orcid]}", 301
    end
    format.rss { builder :show }
    format.bib { @profile.works }
    format.json {@profile.works.to_citeproc.to_json }
  end
end