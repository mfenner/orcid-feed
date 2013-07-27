# -*- coding: utf-8 -*-

require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/respond_to'
require 'faraday'
require 'faraday_middleware'
require 'builder'
require 'rdiscount'
require 'bibtex'
require 'citeproc'
require 'json'

Sinatra::Application.register Sinatra::RespondTo

WORK_TYPES = { "journal-article" => :article,
               "conference-proceedings" => :inproceedings,
               "other" => :misc } 

configure do
  config_file 'config/settings.yml'

  set :environment, :development
  set :default_content, :rss

  mime_type :bib, 'application/x-bibtex'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  markdown :index, :layout_engine => :erb, :layout => :layout
end

get '/:id' do
  @id = params[:id]
  profile = is_orcid?(@id) ? get_profile(@id) : nil

  respond_to do |format|
    format.bib do
      works = get_works(profile)
    end
    format.rss do 
      if profile
        @title = get_name(profile)
        @description = get_biography(profile)
        @items = get_works(profile)
      else
        @title = "Error: No ORCID record for \"#{h params[:id]}\" found." 
        @description = nil
      end
      builder :show
    end
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
    r.url "#{id}/orcid-profile"
    r.headers['Accept'] = 'application/json'
  end

  if response.status == 200
  	profile = response.body['orcid-profile']
  else
  	nil
  end
end

def get_name(profile, reversed=false)
  given_names = profile['orcid-bio']['personal-details']["given-names"]["value"]
  family_name = profile['orcid-bio']['personal-details']["family-name"].nil? ? "" : profile['orcid-bio']['personal-details']["family-name"]["value"]
  name = reversed ? [family_name, given_names].join(", ") : [given_names, family_name].join(" ")
end

def get_biography(profile)
  profile['orcid-bio']['biography'] ? profile['orcid-bio']['biography']['value'] : nil 
end

def get_works(profile)
  # Find all works with citation-type bibtex, convert the rest into bibtex
  if profile["orcid-activities"] and profile["orcid-activities"]["orcid-works"]["orcid-work"]
    works = profile["orcid-activities"]["orcid-works"]["orcid-work"]
    works = works.map do |work| 
      if work["work-citation"] and work["work-citation"]["work-citation-type"].upcase == "BIBTEX"
        s = work["work-citation"]["citation"]
        start = s.index("{") + 1
        stop = s.index(",")
        s[start..stop] = ""
        entry = BibTeX.parse(s, :allow_missing_keys => true)[0]
        entry.key = entry.send(:default_key)
      else
        entry = BibTeX::Entry.new({:type => work["work-type"] ? WORK_TYPES[work["work-type"]] : :misc,
                                   :title => work["work-title"]["title"]["value"],
                                   :author => get_name(profile, true)})
        entry.journal = work["work-title"]["subtitle"]["value"] if work["work-title"]["subtitle"]
        entry.year = work["publication-date"]["year"]["value"] if work["publication-date"]
      end
      if work["work-external-identifiers"] and work["work-external-identifiers"]["work-external-identifier"] and work["work-external-identifiers"]["work-external-identifier"][0]["work-external-identifier-type"].upcase == "DOI"
        doi = work["work-external-identifiers"]["work-external-identifier"][0]["work-external-identifier-id"]["value"]
        entry.doi = doi 
        entry.url = "http://dx.doi.org/#{doi}"
      end
      entry.to_s
    end
    BibTeX.parse(works.join("\n"))
  else
    nil
  end
end