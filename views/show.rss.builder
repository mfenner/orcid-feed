# -*- coding: utf-8 -*-

xml.instruct! :xml, :version => "1.0", :encoding => "utf-8"
  xml.rss :version => "1.0", "xmlns:dc" => "http://purl.org/dc/terms/", "xmlns:prism" => "http://prismstandard.org/namespaces/basic/2.1/" do
    xml.channel do
	  xml.title @title
	  xml.description @description
	  xml.link "http://#{settings.host}/#{@id}.rss"

  	@items.each do |item|
      xml.item do
        xml.title item.title
        xml.link item.url rescue nil
        xml.tag!("dc:title", item.title)
        xml.tag!("dc:publisher", item.publisher) rescue nil
        xml.tag!("dc:creator", item.author)
        xml.tag!("prism:doi", item.doi) rescue nil
        xml.tag!("prism:url", item.url) rescue nil
        xml.tag!("prism:publicationName", item.journal) rescue nil
        xml.tag!("prism:volume", item.volume) rescue nil
        xml.tag!("prism:number", item.number) rescue nil
        xml.tag!("prism:pageRange", item.pages) rescue nil
        xml.tag!("prism:publicationDate", item.year) rescue nil
      end
    end
  end
end