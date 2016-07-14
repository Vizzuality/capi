class ClusteredProjects < CartoDb

  def initialize(hsh)
    @year = hsh[:year]
  end

  def fetch
    @all_sectors = Sector.cached_all
    @results = cached_regions_data
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
    end.sort{ |a,b| b[:people] <=> a[:people] }
  end

  def cached_regions_data
    Rails.cache.fetch(regions_data_cache_key, expires_in: 20.days) do
      puts per_region_query
      ClusteredProjects.send_query(per_region_query)["rows"] || []
    end
  end

  def regions_data_cache_key
    [
      "regions_data",
      @year
    ].join("-")
  end

  def per_region_query
    <<-SQL
      SELECT
      ST_Y(ST_Centroid(st_union(s.the_geom))) AS lat,
      ST_X(ST_Centroid(st_union(s.the_geom))) AS lng,
      s.region_un AS name, p.year,
      sum(p.clim_people) AS clim,
      sum(p.econ_people) AS econ,
      sum(p.educ_people) AS educ,
      sum(p.emer_people) AS emer,
      sum(p.food_people) AS food,
      sum(p.heal_people) AS heal,
      sum(p.refu_people) AS refu,
      sum(p.wate_people) AS wate,
      sum(p.w_g_reached) w_g_reached,
      sum(p.total_peo) AS total_people,
      ntile(3) over(order by sum(p.total_peo) desc) AS bucket
      FROM borders s
      INNER JOIN projects p ON s.iso=p.iso
      WHERE year = #{@year.to_i} AND p.total_peo > 0
      GROUP BY s.region_un, p.year
    SQL
  end
end
