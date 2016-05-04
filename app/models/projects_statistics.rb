class ProjectsStatistics < CartoDb

  attr_reader :end_date

  def initialize hsh
    @end_date = Date.parse(hsh[:end_date]).year : Date.today.year
  end

  def fetch
    results = cached_stats
    return {} unless results
    {
      total_people: results["total_people"],
      total_projects: results["total_projects"]
    }
  end

  def cached_stats
    Rails.cache.fetch(stats_cache_key, expires_in: 3.months) do
      ProjectsStatistics.send_query(stats_query)["rows"].try(:first)
    end
  end

  def stats_cache_key
    [
      "projects-stats",
      "#{@end_date}"
    ].join("-")
  end

  def stats_query
    %Q(
      SELECT SUM(total_peo) AS total_people, SUM(total_projects) AS total_projects
      FROM #{ProjectsStatistics.table_name}
      #{where_clause}
    )
  end

  def where_clause
    if @end_date
      "WHERE year = '#{@end_date}'"
    end
  end

  private

  def self.table_name
    "projects"
  end
end
