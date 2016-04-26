class ProjectsSummary < CartoDb
  COLUMNS = [:lat, :lng, :start_date, :end_date, :sectors_slug]

  attr_reader *COLUMNS

  def initialize(hsh)
    @lat = hsh[:lat]
    @lng = hsh[:lng]
    @start_date = hsh[:start_date]
    @end_date = hsh[:end_date]
    @sectors_slug = hsh[:sectors_slug] && hsh[:sectors_slug].map {|t| "'#{t}'"}.
      join(",")
  end

  def fetch
    @all_sectors = Sector.all
    puts summary_query
    @results = ProjectsSummary.send_query(summary_query)["rows"].try(:first)
    return [] unless @results
    {
      "location": {
        "iso": @results["iso"],
        "name": @results["country"]
      },
      "totals": {
        "projects": total_projects,
        "people": total_people,
        "women_and_girls": @results["w_g_reached"],
        "men": total_people - @results["w_g_reached"]
      },
      "filtered": {
        "projects": filtered_projects,
        "people": filtered_people,
      },
      "sectors": sectors_from
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

  def total_projects
    @all_sectors.inject(0) do |sum, sector|
      sum += @results["#{sector.slug}_projects"]
    end
  end

  def filtered_projects
    @all_sectors.inject(0) do |sum, sector|
      sum += if !@sectors_slug || @sectors_slug.include?(sector.slug)
               @results["#{sector.slug}_projects"]
             else
               0
             end
    end
  end

  def total_people
    @all_sectors.inject(0) do |sum, sector|
      sum += @results["#{sector.slug}_people"]
    end
  end

  def filtered_people
    @all_sectors.inject(0) do |sum, sector|
      sum += if !@sectors_slug || @sectors_slug.include?(sector.slug)
               @results["#{sector.slug}_people"]
             else
               0
             end

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
