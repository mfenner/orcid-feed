# -*- coding: utf-8 -*-

class Work < BibTeX::Entry

  attr_accessor :doi, :url, :number, :volume, :pages

  WORK_TYPES = { article:       "journal-article", 
                 inproceedings: "conference-proceedings",
                 misc:          "other" } 

  def initialize(work, author)
    # if work is already in bibtex format
  	if work["work-citation"] and work["work-citation"]["work-citation-type"].upcase == "BIBTEX"
      entry = BibTeX.parse(work["work-citation"]["citation"])[0]

      # Fix missing or malformed author field
      entry.author = author if entry.author.to_s == ""
      entry.author.gsub!(";", "")
      unless entry.author.to_s.include?("and") or entry.author.to_s.count(" ") < 3
        entry.author = entry.author.gsub(",", " and ")
      end

      super(entry.fields)
      self.type = entry.type
  	else
    	type = WORK_TYPES.index(work["work-type"]) || :misc
    	title = work["work-title"]["title"]["value"]

      super({:type => type,
      	     :title => title,
             :author => author}) 

      # Optional attributes
      self.journal = work["work-title"]["subtitle"]["value"] if work["work-title"]["subtitle"]
      self.year = work["publication-date"]["year"]["value"] if work["publication-date"]
    end

    if work["work-external-identifiers"] and work["work-external-identifiers"]["work-external-identifier"] and work["work-external-identifiers"]["work-external-identifier"][0]["work-external-identifier-type"].upcase == "DOI"
      doi = work["work-external-identifiers"]["work-external-identifier"][0]["work-external-identifier-id"]["value"]
      self.doi = doi 
      self.url = "http://dx.doi.org/#{doi}"
    end
  end
end