class DonationsStatistics < CartoDb

  attr_reader :start_date, :end_date, :sectors_slug, :countries_iso

  def initialize hsh
    @start_date = hsh[:start_date] ? Date.parse(hsh[:start_date]) : nil
    @end_date = hsh[:end_date] ? Date.parse(hsh[:end_date]) : nil
    @sectors_slug = hsh[:sectors_slug] && hsh[:sectors_slug].map {|t| "'#{t}'"}.
      join(",")
    @countries_iso = hsh[:countries_iso] && hsh[:countries_iso].map {|t| "'#{t}'"}.
      join(",")
  end

  def fetch
    results = DonationsStatistics.send_query(stats_query)["rows"].try(:first)
    return {} unless results
    {
      total_donations: results["total_donations"],
      total_funds: results["total_funds"]
    }
  end

  def stats_query
    %Q(
      SELECT COUNT(*) AS total_donations, SUM(amount) AS total_funds
      FROM #{DonationsStatistics.table_name}
      #{where_clause}
    )
  end

  def where_clause
    q = []
    if @start_date && @end_date
      q << ["date BETWEEN '#{@start_date}' AND '#{@end_date}'"]
    end
    if @sectors_slug
      q << ["sectors %26%26 ARRAY[#{@sectors_slug}]"]
    end
    if @countries_iso
      q << ["countries %26%26 ARRAY[#{@countries_iso}]"]
    end
    return q.empty? ? "" : "WHERE " + q.join(" AND ")
  end

  private

  def self.table_name
    "donors"
  end
end
