xml.instruct! :xml, :version => "1.0"
  xml.rss :version => "1.0" do
    xml.channel do
	  xml.title "Error"
	  xml.description "No ORCID record found."	
  end
end