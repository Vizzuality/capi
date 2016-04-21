class DonationsSummary < CartoDb
  COLUMNS = [:lat, :lng, :start_date, :end_date, :sectors_slug,
             :countries_slug]

  attr_reader *COLUMNS

  def initialize(hsh)
    COLUMNS.each do |col|
      instance_variable_set("@#{col.to_s}", hsh[col.to_s])
    end
  end

  def fetch
    @all_sectors = Sector.all
    @all_countries = Country.all
    @results = DonationsSummary.send_query(summary_query)["rows"].try(:first)
    return [] unless @results
    {
      "location": {
        "iso": @results["country_iso"],
        "name": @results["country"],
        "city": @results["city"],
        "state": @results["state"]
      },
      "total_funds": @results["total_funds"],
      "total_donors": @results["total_donors"],
      "donors": @results["donations"],
      "sectors": sectors_of_interest,
      "countries": countries_of_interest
    }
  end

  def summary_query
    %Q(
      SELECT
      city, country, state, country_iso,
      SUM(amount) AS total_funds,
      COUNT(*) AS total_donors,
      array_agg(
        CASE WHEN historical_donation = 'f'
        THEN nickname || ' - $' || amount
          ELSE NULL END
      ) AS donations,
      array_agg(replace(countries, '|', ',')) FILTER (
        WHERE countries <> '' OR countries IS NOT NULL
      ) AS countries_agg,
      array_agg(sectors) AS sectors_agg
      FROM #{DonationsSummary.table_name} AS donors
      WHERE
        ST_CONTAINS(
          ST_Buffer(ST_SetSRID(ST_MakePoint(#{@lng}, #{@lat}), 4326), 0.1),
          donors.the_geom)
      #{where_clause}
      GROUP by city, country, state, country_iso
    )
  end

  def where_clause
    if @start_date && @end_date
      "AND date BETWEEN #{Date.parse(@start_date)} AND #{Date.parse(@end_date)}"
    else
      ""
    end
  end

  def sectors_of_interest
    sectors = []
    @results["sectors_agg"].compact.group_by{|x| x}.
      sort_by{|k, v| -v.size}.map(&:first)[0,3].each do |slug|
      sectors << {
        slug: slug,
        name: @all_sectors.select{|s| s.slug == slug}.first.try(:name)
      }
    end
    sectors
  end

  def countries_of_interest
    countries = []
    return [] unless @results["countries_agg"]
    @results["countries_agg"].compact.group_by{|x| x}.
      sort_by{|k, v| -v.size}.map(&:first)[0,3].each do |iso|
      countries << {
        iso: iso,
        name: @all_countries.select{|s| s.iso == iso}.first.try(:name)
      }
    end
    countries
  end

  private

  def project_cols
    @all_sectors.map{|s| "SUM(#{s.slug}_projects) AS #{s.slug}_projects"}
  end

  def people_cols
    @all_sectors.map{|s| "SUM(#{s.slug}_people) AS #{s.slug}_people"}
  end

  def self.table_name
    "donors"
  end
end
