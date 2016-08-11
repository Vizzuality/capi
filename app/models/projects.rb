class Projects < CartoDb
  def initialize(hsh)
    @year = hsh[:year]
  end

  def fetch
    @all_sectors = Sector.cached_all
    @results = cached_projects_data
    @results.map do |r|
      {
        name: r["name"],
        iso: r["iso"],
        total_people: r["total_people"],
        lat: r["lat"],
        lng: r["lng"],
        is_country_office: r["is_country_office"] || true,
        clustered: self.class == Projects::Clustered ? true : false,
        bucket: r["bucket"],
        per_sector: per_sector_data(r)
      }
    end
  end

  def per_sector_data r
    @all_sectors.map do |sector|
      {
        slug: sector.slug,
        color: sector.color,
        people: r[sector.slug] || 0
      }
    end.sort { |a,b| b[:people] <=> a[:people] }[0,self.class::SECTORS_LIMIT].
    reject { |a| a[:people] <= 0 }
  end

  def cached_projects_data
    Rails.cache.fetch(projects_data_cache_key, expires_in: 20.days) do
      self.class.send_query(projects_query)["rows"] || []
    end
  end

  private

  def projects_data_cache_key
    raise 'needs to be implemented'
  end

  def projects_query
    raise 'needs to be implemented'
  end
end
