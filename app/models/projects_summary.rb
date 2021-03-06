class ProjectsSummary < CartoDb
  COUNTRY_URLS = [
    ["ALB", "http://www.careinternational.org.uk/countries/albania"],
    ["AUS", "http://www.care.org.au"],
    ["AUT", "http://www.care.at"],
    ["BEL", "http://www.care-international.org/"],
    ["BIH", "http://www.care.org/country/bosnia-and-herzegovina"],
    ["CAN", "http://www.care.ca"],
    ["CHE", "http://www.care-international.org/"],
    ["CIV", "http://www.care.org/country/cote-divoire"],
    ["COD", "http://www.care.org/country/democratic-republic-congo"],
    ["CZE", "http://www.care.cz"],
    ["DEU", "https://www.care.de/"],
    ["DNK", "http://www.care.dk"],
    ["FRA", "http://www.carefrance.org"],
    ["GBR", "http://www.careinternational.org.uk/"],
    ["IRQ", nil],
    ["LKA", "http://www.care.org/country/sri-lanka"],
    ["PNG", "http://www.care.org/country/papua-new-guinea"],
    ["SLE", "http://www.care.org/country/sierra-leone"],
    ["SSD", "http://www.care.org/country/south-sudan"],
    ["TLS", "http://www.care.org/country/timor-leste"],
    ["USA", "http://www.care.org"],
    ["WBG", "http://www.care.org/country/west-bankgaza"]
  ]

  COLUMNS = [:year, :iso]

  attr_reader *COLUMNS

  def initialize(hsh)
    @year = hsh[:year] || (Date.today.year-1)
    @iso = hsh[:iso]
  end

  def fetch
    @all_sectors = Sector.cached_all.select{|s| s.filter_for_projects }
    @results = cached_summary
    puts summary_query
    return {} unless @results.present?

    if @results["w_g_reached"] && @results["w_g_reached"] > 0 &&
        @results["total_peo"].present? && @results["total_peo"] > 0
      women_percent = (@results["w_g_reached"].to_f * 100.0 )/ @results["total_peo"].to_f
    else
      women_percent = nil
    end
    country_match = COUNTRY_URLS.select{|t| t[0] == @iso}.first
    url = if country_match
            country_match[1]
          else
            "http://www.care.org/country/#{@results["country"].gsub(" ", "-").downcase.dasherize}"
          end
    {
      "location": {
        "iso": @iso,
        "name": @results["country"]
      },
      "totals": {
        "projects": @results["total_projects"],
        "people": @results["total_peo"],
        "women_and_girls": women_percent
      },
      "sectors": sectors_from,
      "is_country_office": @results["is_country_office"],
      "url": url,
      "year": @year
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
      "#{@iso}",
      "#{@year}"
    ].join("-")
  end

  def summary_query
    %Q(
      SELECT projects.country, projects.iso,
      total_peo, total_projects, w_g_reached,
      (reached_per_pop*100) as reached_per_pop, #{project_cols.join(", ")},
      #{people_cols.join(", ")},
      is_co AS is_country_office
      FROM #{ProjectsSummary.table_name} AS projects
      WHERE projects.iso = '#{@iso}'
      AND total_peo >= 0 AND year = #{@year}
    )
  end

  def cached_refugees
    Rails.cache.fetch(refugees_cache_key, expires_in: 20.days) do
      ProjectsSummary.send_query(refugees_query)["rows"]
    end
  end

  def sectors_from
    sectors = []
    @all_sectors.each do |sector|
      if @results["#{sector.slug}_projects"] &&
          @results["#{sector.slug}_projects"] > 0
        sectors << {
          slug: sector.slug,
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
