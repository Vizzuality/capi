class ProjectsStatistics < CartoDb

  attr_reader :start_date, :end_date

  def initialize hsh
    @start_date = hsh[:start_date]
    @end_date = hsh[:end_date]
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
      "#{@start_date}",
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
    if @start_date && @end_date
      "WHERE date BETWEEN '#{Date.parse(@start_date)}' AND '#{Date.parse(@end_date)}'"
    end
  end

  private

  def self.table_name
    "projects"
  end
end
