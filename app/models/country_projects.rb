class CountryProjects < CartoDb

  def initialize(hsh)
    @year = hsh[:year]
  end

  def fetch
    @all_sectors = Sector.cached_all
    @results = cached_countrys_data
    @results.map do |r|
      {
        name: r["name"],
        total_people: r["total_people"],
        lat: r["lat"],
        lng: r["lng"],
        clustered: true,
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
    end.sort{ |a,b| b[:people] <=> a[:people] }[0,3]
  end

  def cached_countrys_data
    Rails.cache.fetch(countrys_data_cache_key, expires_in: 20.days) do
      puts per_country_query
      CountryProjects.send_query(per_country_query)["rows"] || []
    end
  end

  def countrys_data_cache_key
    [
      "countries_data",
      @year
    ].join("-")
  end

  def per_country_query
    <<-SQL
      SELECT
      ST_Y(ST_Centroid(s.the_geom)) AS lat,
      ST_X(ST_Centroid(s.the_geom)) AS lng,
      s.name, p.year,
      p.clim_people AS clim,
      p.econ_people AS econ,
      p.educ_people AS educ,
      p.emer_people AS emer,
      p.food_people AS food,
      p.heal_people AS heal,
      p.refu_people AS refu,
      p.wate_people AS wate,
      p.w_g_reached w_g_reached,
      p.total_peo AS total_people,
      ntile(4) over(order by p.total_peo desc) AS bucket
      FROM borders s
      INNER JOIN projects p ON s.iso=p.iso
      WHERE year = #{@year.to_i} AND p.total_peo > 0
    SQL
  end
end
