class ProjectsSummary < CartoDb
  COLUMNS = [:lat, :lng, :start_date, :end_date, :sectors_slug]

  attr_reader *COLUMNS

  def initialize(hsh)
    COLUMNS.each do |col|
      instance_variable_set("@#{col.to_s}", hsh[col.to_s])
    end
  end

  def fetch
    @all_sectors = Sector.all
    @results = ProjectsSummary.send_query(summary_query)["rows"].try(:first)
    return [] unless @results
    {
      "location": {
        "iso": @results["iso"],
        "name": @results["country"]
      },
      "number_of_projects": number_of_projects,
      "sectors": sectors_from,
      "people_reached": people_reached,
      "women_and_girls_total": @results["w_g_reached"],
      "men_total": people_reached - @results["w_g_reached"]
    }
  end

  def summary_query
    %Q(
      SELECT projects.country, projects.iso,
      #{project_cols.join(", ")},
      #{people_cols.join(", ")},
      SUM(w_g_reached) AS w_g_reached
      FROM #{ProjectsSummary.table_name} AS projects
      INNER JOIN #{Country.table_name} AS countries ON
      countries.iso = projects.iso
      WHERE ST_CONTAINS(countries.the_geom, ST_SetSRID(ST_MakePoint(
      #{@lng}, #{@lat}), 4326))
      #{where_clause}
      GROUP by projects.country, projects.iso
    )
  end

  def where_clause
    if @start_date && @end_date
      "AND year BETWEEN #{Date.parse(@start_date).year} AND #{Date.parse(@end_date).year}"
    else
      ""
    end
  end

  def number_of_projects
    @all_sectors.inject(0) do |sum, sector|
      sum += @results["#{sector.slug}_projects"]
    end
  end

  def people_reached
    @all_sectors.inject(0) do |sum, sector|
      sum += @results["#{sector.slug}_people"]
    end
  end

  def sectors_from
    sectors = []
    @all_sectors.each do |sector|
      if @results["#{sector.slug}_projects"].present? &&
          @results["#{sector.slug}_projects"] > 0
        sectors << {
          slug: sector.slug,
          name: sector.name,
          number_projects: @results["#{sector.slug}_projects"],
          number_people: @results["#{sector.slug}_people"],
        }
      end
    end
    sectors
  end

  private

  def project_cols
    @all_sectors.map{|s| "SUM(#{s.slug}_projects) AS #{s.slug}_projects"}
  end

  def people_cols
    @all_sectors.map{|s| "SUM(#{s.slug}_people) AS #{s.slug}_people"}
  end

  def self.table_name
    "projects"
  end
end
