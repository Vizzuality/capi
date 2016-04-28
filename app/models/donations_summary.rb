class DonationsSummary < CartoDb
  COLUMNS = [:lat, :lng, :start_date, :end_date, :sectors_slug,
             :countries_iso, :zoom]

  attr_reader *COLUMNS

  def initialize(hsh)
    @lat = hsh[:lat]
    @lng = hsh[:lng]
    @zoom = hsh[:zoom].to_i
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
    puts summary_query
    @results = DonationsSummary.send_query(summary_query)["rows"].try(:first)
    return [] unless @results
    {
      "location": {
        "iso": @results["country_iso"],
        "country": @results["country"],
        "city": @results["city"],
        "state": @results["state"]
      },
      "total_funds": @results["total_funds"],
      "total_donors": @results["total_donors"],
      "donors": @results["donations"].compact,
      "sectors": @results["sectors_agg"] ? sectors_of_interest : [],
      "countries": @results["countries_agg"] ? countries_of_interest : []
    }
  end

  def summary_query
    %Q(
      SELECT
      city, country, state, country_iso,
      SUM(amount) AS total_funds,
      COUNT(*) AS total_donors,
      array_agg(
        CASE WHEN historical_donation = 't'
        THEN nickname || ' - $' || amount
          ELSE NULL END
      ) AS donations,
      array_agg(replace(countries, '|', ',')) FILTER (
        WHERE countries <> '' OR countries IS NOT NULL
      ) AS countries_agg,
      array_agg(sectors) FILTER (
        WHERE sectors <> '' OR sectors IS NOT NULL
      ) AS sectors_agg
      FROM #{DonationsSummary.table_name} AS donors
      WHERE
        ST_CONTAINS(
          ST_Buffer(ST_SetSRID(ST_MakePoint(#{@lng}, #{@lat}), 4326),
          #{get_radius_buffer}),
          donors.the_geom)
      #{where_clause}
      GROUP by city, country, state, country_iso
      ORDER by total_donors DESC, total_funds DESC
    )
  end

  def where_clause
    q = []
    if @start_date && @end_date
      q << "date BETWEEN #{Date.parse(@start_date)} AND #{Date.parse(@end_date)}"
    end
    if @sectors_slug
      q << ["string_to_array(sectors, ',') %26%26 ARRAY[#{@sectors_slug}]"]
    end
    if @countries_iso
      q << ["string_to_array(countries, '|') %26%26 ARRAY[#{@countries_iso}]"]
    end
    return q.empty? ? "" : "AND " + q.join(" AND ")
  end

  def sectors_of_interest
    sectors = []
    @results["sectors_agg"].compact.map{|t| t.split(",")}.flatten.
      group_by{|x| x}.sort_by{|k, v| -v.size}.map(&:first)[0,3].each do |slug|
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
    @results["countries_agg"].compact.map{|t| t.split(",")}.flatten
      .group_by{|x| x}.sort_by{|k, v| -v.size}.map(&:first)[0,3].each do |iso|
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

  def get_radius_buffer
    if [10,9].include?(@zoom)
      0.01
    elsif [7,8].include?(@zoom)
      0.03
    elsif @zoom == 6
      0.06
    elsif @zoom == 5
      0.13
    elsif @zoom == 4
      0.25
    elsif @zoom == 3
      0.6
    elsif @zoom == 2
      1
    elsif @zoom == 1
      1.2
    end
  end

  def self.table_name
    "donors"
  end
end
