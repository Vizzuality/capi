class RefugeesSummary < CartoDb
  COLUMNS = [:lat, :lng, :end_date]

  attr_reader *COLUMNS

  def initialize(hsh)
    @lat = hsh[:lat]
    @lng = hsh[:lng]
    @end_date = hsh[:end_date] ? Date.parse(hsh[:end_date]).year : (Date.today.year-1)
  end

  def fetch
    @country = Country.fetch_country_for @lat, lng
    return [] unless @country
    refugees = cached_summary
    return [] unless refugees.present?
    {
      "location": {
        "iso": @country["iso"],
        "name": @country["name"]
      },
      "year": @end_date
    }.merge!(parse_crisis(refugees))
  end

  def cached_summary
    Rails.cache.fetch(summary_cache_key, expires_in: 20.days) do
      RefugeesSummary.send_query(summary_query)["rows"]
    end
  end

  def summary_cache_key
    "refugees-summary-#{@country["iso"]}-#{@end_date}"
  end

  def summary_query
    %(
     SELECT projects.crisis, projects.country, projects.crisis_iso,
     projects.iso, projects.year
     FROM refugees_projects AS projects
     WHERE year = #{@end_date}
      AND (
        projects.crisis_iso = '#{@country["iso"]}' OR
        projects.iso = '#{@country["iso"]}'
      )
    )
  end

  def parse_crisis hsh
    all_countries = Country.cached_all
    result = { crisis_local: [], crisis_aiding: []}
    hsh.group_by{|t| t["crisis_iso"]}.each do |crisis_iso, details|
      if crisis_iso == @country["iso"]
        details.group_by{ |t| t["crisis"] }.each do |name, info|
          crisis = {}
          crisis[:name] = name
          crisis[:parties_involved] = []
          info.each do |d|
            crisis[:parties_involved] << {
              country: d["country"],
              iso: d["iso"]
            }
          end
          result[:crisis_local] << crisis
        end
      else
        crisis = {}
        details.each do |d|
          crisis[:name] = d["crisis"]
          crisis[:iso] = crisis_iso
          crisis[:country] = all_countries.select{ |c| c.iso == crisis_iso}.
            first.name
        end
        result[:crisis_aiding] << crisis
      end
    end
    result
  end
end
