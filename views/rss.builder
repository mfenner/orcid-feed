xml.instruct! :xml, :version => "1.0"
  xml.rss :version => "1.0" do
    xml.channel do
	  xml.title @title
	  xml.description @description
  end
end