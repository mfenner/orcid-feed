atom_feed(:root_url => @user.orcid.blank? ? user_path(@user.username) : "http://orcid.org/#{@user.orcid}", :schema_date => 2012) do |feed|
  feed.title "Publications by #{@user.name}" + (@user.orcid.blank? ? "" : " (#{@user.orcid})")
  feed.updated @user.articles.maximum(:created_at)
  
  @user.articles.order("updated_at DESC").each do |article|
    feed.entry(article, :url => "http://dx.doi.org/#{article.doi}", :published => article.published_on.blank? ? article.created_at : article.published_on.to_time.utc) do |entry|
      entry.title article.title
    end
  end
end