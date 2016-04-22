class DonationsDistribution < CartoDb
  COLUMNS = [:lat, :lng, :start_date, :end_date, :sectors_slug,
             :countries_iso]

  attr_reader *COLUMNS

  def initialize(hsh)
    @lat = hsh[:lat]
    @lng = hsh[:lng]
    @start_date = hsh[:start_date]
    @end_date = hsh[:end_date]
    @sectors_slug = hsh[:sectors_slug] && hsh[:sectors_slug].map {|t| "'#{t}'"}.
      join(",")
    @countries_iso = hsh[:countries_iso] && hsh[:countries_iso].map {|t| "'#{t}'"}.
      join(",")
  end

  def fetch
    @all_sectors = Sector.all
    @all_countries = Country.all
    @results = DonationsDistribution.send_query(distribution_query)["rows"].
      try(:first)
    return [] unless @results
    {
      "location": {
        "iso": @results["country_iso"],
        "country": @results["country"]
      },
      "total_funds": @results["total_funds"],
      "total_donors": @results["total_donors"]
    }
  end

  def distribution_query
    %Q(
      SELECT
      country, country_iso,
      SUM(amount) AS total_funds,
      COUNT(*) AS total_donors
      FROM #{DonationsDistribution.table_name} AS donors
      INNER JOIN #{Country.table_name} AS countries ON
      countries.iso = donors.country_iso
      WHERE ST_CONTAINS(countries.the_geom, ST_SetSRID(ST_MakePoint(
      #{@lng}, #{@lat}), 4326))
      #{where_clause}
      GROUP by country_iso, country
      ORDER BY total_donors DESC
    )
  end

  def where_clause
    q = []
    if @start_date && @end_date
      q << "date BETWEEN #{Date.parse(@start_date)} AND #{Date.parse(@end_date)}"
    end
    if @sectors_slug
      q << ["string_to_array(sectors, ',') %26%26 string_to_array(#{@sectors_slug}, ',')"]
    end
    if @countries_iso
      q << ["string_to_array(countries, '|') %26%26 string_to_array(#{@countries_iso}, ',')"]
    end
    return q.empty? ? "" : "AND " + q.join(" AND ")
  end

  private

  def self.table_name
    "donors"
  end
end
