# require 'json'

module Orcid

  def logger
    Log4r::Logger['test']    
  end

  def get_profile
    # logger.debug "retrieving ORCID profile for #{session[:orcid][:uid]}"
    # response = auth_token.get "#{session[:orcid][:uid]}/orcid-profile", :headers => {'Accept' => 'application/json'}
    # if response.status == 200
    #   json = JSON.parse(response.body)
    #   given_name = json['orcid-profile']['orcid-bio']['personal-details']['given-names']['value']
    #   family_name = json['orcid-profile']['orcid-bio']['personal-details']['family-name']['value']
    #   other_names = json['orcid-profile']['orcid-bio']['personal-details']['other-names'].nil? ? nil : json['orcid-profile']['orcid-bio']['personal-details']['other-names']['other-name']
    #   logger.info "Got updated profile data: " + session[:orcid].ai
    # end
  end

  def is_orcid?(string)
    string.strip =~ /\A[0-9]{4}\-[0-9]{4}\-[0-9]{4}\-[0-9]{3}[0-9X]\Z/
  end
end