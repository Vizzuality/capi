class Projects::Clustered < Projects

  SECTORS_LIMIT = 6

  private

  def projects_data_cache_key
    [
      "regions_data",
      @year
    ].join("-")
  end

  def projects_query
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
      sum(p.wate_people) AS wate,
      sum(p.total_peo) AS total_people,
      ntile(3) over(order by sum(p.total_peo) desc) AS bucket
      FROM borders s
      INNER JOIN projects p ON s.iso=p.iso
      WHERE year = #{@year.to_i} AND p.total_peo > 0
      GROUP BY s.region_un, p.year
    SQL
  end
end
