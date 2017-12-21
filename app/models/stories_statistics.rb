class StoriesStatistics < CartoDb

    def fetch
      results = cached_stats
      return {} unless results
      {
        total_stories: results["total"]
      }
    end

    def cached_stats
      Rails.cache.fetch(stats_cache_key, expires_in: 3.months) do
        StoriesStatistics.send_query(stats_query)["rows"].try(:first)
      end
    end

    def stats_cache_key
      [
        "stories-stats",
        "#{Date.today}"
      ].join("-")
    end

    def stats_query
      %Q(
        SELECT COUNT(*) as total
        FROM #{StoriesStatistics.table_name}
      )
    end

    private

    def self.table_name
      "output_stories"
    end
  end
