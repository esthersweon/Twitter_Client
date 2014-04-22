fetched_timeline = Status.fetch_by_twitter_user_id!(973274587)
Status.parse_json(fetched_timeline)