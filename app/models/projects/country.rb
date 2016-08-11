class Projects::Country < Projects

  SECTORS_LIMIT = 3

  private

  def projects_data_cache_key
    [
      "countries_data",
      @year
    ].join("-")
  end

  def projects_query
    <<-SQL
      SELECT
      ST_Y(ST_Centroid(s.the_geom)) AS lat,
      ST_X(ST_Centroid(s.the_geom)) AS lng,
      s.name, p.year,
      s.iso,
      p.clim_people AS clim,
      p.econ_people AS econ,
      p.educ_people AS educ,
      p.emer_people AS emer,
      p.food_people AS food,
      p.heal_people AS heal,
      p.wate_people AS wate,
      p.total_peo AS total_people,
      p.is_co AS is_country_office,
      ntile(4) over(order by p.total_peo desc) AS bucket
      FROM borders s
      INNER JOIN projects p ON s.iso=p.iso
      WHERE year = #{@year.to_i} AND p.total_peo >= 0
    SQL
  end
end
