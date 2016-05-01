class ProjectsSummary < CartoDb
  COLUMNS = [:lat, :lng, :end_date, :sectors_slug]

  attr_reader *COLUMNS

  def initialize(hsh)
    @lat = hsh[:lat]
    @lng = hsh[:lng]
    @end_date = hsh[:end_date] ? Date.parse(hsh[:end_date]) : nil
    @sectors_slug = hsh[:sectors_slug]
  end

  def fetch
    @all_sectors = Sector.all.select{|s| s.filter_for_projects }
    puts summary_query
    @results = ProjectsSummary.send_query(summary_query)["rows"].try(:first)
    return [] unless @results

    if @results["w_g_reached"].present? && @results["w_g_reached"] > 0 &&
        @results["total_peo"].present? && @results["total_peo"] > 0
      women_percent = (@results["w_g_reached"].to_f * 100.0 )/ @results["total_peo"].to_f
    else
      women_percent = nil
    end
    {
      "location": {
        "iso": @results["iso"],
        "name": @results["country"]
      },
      "totals": {
        "projects": @results["total_projects"],
        "people": @results["total_peo"],
        "women_and_girls": women_percent
      },
      "sectors": sectors_from,
      "url": "http://www.care.org/country/#{@results["country"].downcase.dasherize}",
      "year": @end_date.try(:year) || (Date.today.year-1)
    }
  end

  def summary_query
    %Q(
      SELECT projects.country, projects.iso,
      total_peo, total_projects, w_g_reached,
      #{project_cols.join(", ")},
      #{people_cols.join(", ")}
      FROM #{ProjectsSummary.table_name} AS projects
      INNER JOIN #{Country.table_name} AS countries ON
      countries.iso = projects.iso
      WHERE ST_CONTAINS(countries.the_geom, ST_SetSRID(ST_MakePoint(
      #{@lng}, #{@lat}), 4326))
      #{where_clause}
    )
  end

  def where_clause
    q = []
    q << if @end_date
           "AND year = #{@end_date.year}"
         else
           "AND year = #{Date.today.year-1}"
         end
    if @sectors_slug
      sectors = []
      @sectors_slug.each do |s|
        sectors << "#{s}_people <> 0"
      end
      q << "(#{sectors.join(" OR ")})"
    end
    q.join(" AND ")
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
    sectors.sort{|a,b| b[:number_people] <=> a[:number_people]}
  end

  private

  def project_cols
    @all_sectors.map{|s| "#{s.slug}_projects"}
  end

  def people_cols
    @all_sectors.map{|s| "#{s.slug}_people"}
  end

  def self.table_name
    "projects"
  end
end
