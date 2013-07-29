# -*- coding: utf-8 -*-

xml.instruct! :xml, :version => "1.0", :encoding => "utf-8"
  xml.rss :version => "1.0", "xmlns:dc" => "http://purl.org/dc/terms/", "xmlns:prism" => "http://prismstandard.org/namespaces/basic/2.1/" do
    xml.channel do
	  xml.title @profile.name
	  xml.description @profile.biography
	  xml.link "http://#{settings.host}/#{@profile.orcid}.rss"
    xml.tag!("dc:rights", "http://creativecommons.org/publicdomain/zero/1.0/")
    xml.tag!("dc:date", @profile.updated_at.iso8601)

  	@profile.works.each do |work|
      xml.item do
        xml.title work.title
        xml.link work.url rescue nil
        xml.tag!("dc:title", work.title)
        xml.tag!("dc:publisher", work.publisher) if work.publisher
        xml.tag!("dc:creator", work.author)
        xml.tag!("prism:doi", work.doi) rescue nil
        xml.tag!("prism:url", work.url) rescue nil
        xml.tag!("prism:publicationName", work.journal) if work.journal
        xml.tag!("prism:volume", work.volume) rescue nil
        xml.tag!("prism:number", work.number) rescue nil
        xml.tag!("prism:pageRange", work.pages) if work.pages
        xml.tag!("prism:publicationDate", work.year)
      end
    end
  end
end