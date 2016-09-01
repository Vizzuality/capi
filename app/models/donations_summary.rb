class DonationsSummary < CartoDb
  COLUMNS = [:lat, :lng, :start_date, :end_date, :sectors_slug,
             :countries_iso, :zoom]

  DONORS_SEPARATOR = "###"

  attr_reader *COLUMNS

  def initialize(hsh)
    @lat = hsh[:lat]
    @lng = hsh[:lng]
    @zoom = hsh[:zoom] ? hsh[:zoom].to_i : 9
    @start_date = hsh[:start_date] ? Date.parse(hsh[:start_date]).strftime("%m-%d-%Y") : nil
    @end_date = hsh[:end_date] ? Date.parse(hsh[:end_date]).strftime("%m-%d-%Y") : nil
    @sectors_slug = hsh[:sectors_slug] && hsh[:sectors_slug].map {|t| "'#{t}'"}.
      join(",")
    @countries_iso = hsh[:countries_iso] && hsh[:countries_iso].map {|t| "'#{t}'"}.
      join(",")
  end

  def fetch
    @all_sectors = Sector.cached_all
    @all_countries = Country.cached_all
    puts summary_query
    @results = DonationsSummary.send_query(summary_query)["rows"].try(:first)
    return [] unless @results
    donors = @results["donations"].empty? ? [] : @results["donations"].
      compact.map{|t| t.split(DONORS_SEPARATOR)}.
      sort{|a,b| Date.parse(a[2]) <=> Date.parse(b[2])}
    {
      "location": {
        "iso": @results["country_iso"],
        "country": @results["country"],
        "city": @results["city"],
        "state": @results["state"]
      },
      "total_funds": @results["total_funds"],
      "total_donors": @results["total_donors"],
      "donors": donors.map { |d|
        {
          name: d[0],
          amount: d[1],
          date: Date.parse(d[2])
        }
      },
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
        THEN NULL
        ELSE nickname || '#{DONORS_SEPARATOR}' || amount ||
        '#{DONORS_SEPARATOR}' || date
        END
      ) AS donations,
      array_agg(array_to_string(countries, ',')) FILTER (
        WHERE countries <> '{}' OR countries IS NOT NULL
      ) AS countries_agg,
      array_agg(array_to_string(sectors, ',')) FILTER (
        WHERE sectors <> '{}' OR sectors IS NOT NULL
      ) AS sectors_agg
      FROM #{DonationsSummary.table_name} AS donors
      WHERE
        ST_CONTAINS(
         ST_Buffer(ST_Transform(ST_SetSRID(ST_MakePoint(#{@lng}, #{@lat}), 4326), 3857),
          CDB_XYZ_Resolution(#{@zoom}) * 8),
         ST_SnapToGrid(the_geom_webmercator, CDB_XYZ_Resolution(#{@zoom}) * 2)
        )
      #{where_clause}
      GROUP by city, country, state, country_iso
      ORDER by total_donors DESC, total_funds DESC
    )
  end

  def where_clause
    q = []
    if @end_date
      q << "date >= '#{@end_date}'::DATE AND date <  ('#{@end_date}'::DATE+7)"
    end
    if @sectors_slug
      q << ["sectors %26%26 ARRAY[#{@sectors_slug}]"]
    end
    if @countries_iso
      q << ["countries %26%26 ARRAY[#{@countries_iso}]"]
    end
    return q.empty? ? "" : "AND " + q.join(" AND ")
  end

  def sectors_of_interest
    sectors = []
    @results["sectors_agg"].compact.map{|t| t.split(",")}.flatten.
      group_by{|x| x}.sort_by{|k, v| -v.size}.map(&:first)[0,3].each do |slug|
      name = @all_sectors.select{|s| s.slug == slug}.first.try(:name)
      if name
        sectors << {
          slug: slug,
          name: name
        }
      end
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

  def get_radius_buffer
    if @zoom >= 9
      0.05
    elsif @zoom == 8
      0.10
    elsif @zoom == 7
      0.15
    elsif @zoom == 6
      0.20
    elsif @zoom == 5
      0.25
    elsif @zoom == 4
      0.35
    elsif @zoom == 3
      0.6
    elsif @zoom == 2
      1
    elsif @zoom == 1
      1.2
    else
      1.4
    end
  end

  def self.table_name
    ENV["DONORS_TABLE"] || "donors"
  end
end
