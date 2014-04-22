require 'launchy'
require 'json'
require 'addressable/uri'

class Status # < ActiveRecord::Base
  # validates :text, :twitter_status_id, :twitter_user_id, :presence => true

  def self.fetch_by_twitter_user_id!(user_id)
    TwitterSession.get("statuses/user_timeline", {:user_id => user_id})
  end

  def self.parse_json(fetched_timeline)
    txt = fetched_timeline[0]["text"]
    user_id = fetched_timeline[0]["user"]["id"]
    status_id = fetched_timeline[0]["id_str"]

    Status.new(txt, status_id, user_id)
  end



end
