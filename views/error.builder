xml.instruct! :xml, :version => "1.0"
  xml.rss :version => "1.0" do
    xml.channel do
	  xml.title "Error: No ORCID record for \"#{@id}\" found."	
  end
end