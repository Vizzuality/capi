class ProjectsSummary < CartoDb
  COLUMNS = [:lat, :lng, :end_date, :sectors_slug]

  attr_reader *COLUMNS

  def initialize(hsh)
    @lat = hsh[:lat]
    @lng = hsh[:lng]
    @end_date = hsh[:end_date] ? Date.parse(hsh[:end_date]).year : (Date.today.year-1)
    @sectors_slug = hsh[:sectors_slug]
  end

  def fetch
    @all_sectors = Sector.cached_all.select{|s| s.filter_for_projects }
    @country = Country.fetch_country_for @lat, @lng
    return [] unless @country
    @results = cached_summary
    puts summary_query
    return [] unless @results.present?

    if @results["w_g_reached"] && @results["w_g_reached"] > 0 &&
        @results["total_peo"].present? && @results["total_peo"] > 0
      women_percent = (@results["w_g_reached"].to_f * 100.0 )/ @results["total_peo"].to_f
    else
      women_percent = nil
    end
    {
      "location": {
        "iso": @country["iso"],
        "name": @country["name"]
      },
      "totals": {
        "projects": @results["total_projects"],
        "people": @results["total_peo"],
        "women_and_girls": women_percent
      },
      "sectors": sectors_from,
      "url": "http://www.care.org/country/#{@country["name"].downcase.dasherize}",
      "year": @end_date
    }
  end

  def cached_summary
    Rails.cache.fetch(summary_cache_key, expires_in: 20.days) do
      ProjectsSummary.send_query(summary_query)["rows"].try(:first) || {}
    end
  end

  def summary_cache_key
    [
      "summary",
      "#{@country["iso"]}",
      "#{@end_date}",
      "#{@sectors_slug ? @sectors_slug.join("-") : ""}"
    ].join("-")
  end

  def summary_query
    %Q(
      SELECT projects.country, projects.iso,
      total_peo, total_projects, w_g_reached,
      #{project_cols.join(", ")},
      #{people_cols.join(", ")}
      FROM #{ProjectsSummary.table_name} AS projects
      WHERE projects.iso = '#{@country["iso"]}'
      #{where_clause}
    )
  end

  def cached_refugees
    Rails.cache.fetch(refugees_cache_key, expires_in: 20.days) do
      ProjectsSummary.send_query(refugees_query)["rows"]
    end
  end

  def where_clause
    q = []
    q << "AND year = #{@end_date}"
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
      if @results["#{sector.slug}_projects"] &&
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

  def parse_crisis hsh
    result = []
    hsh.group_by{|t| t["crisis"]}.each do |name, details|
      crisis = {}
      crisis["name"] = name
      crisis["parties_involved"] = []
      details.each do |d|
        crisis["parties_involved"] << {
          country: d["country"],
          iso: d["iso"]
        }
      end
      result << crisis
    end
    result
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
