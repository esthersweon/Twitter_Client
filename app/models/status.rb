require 'launchy'
require 'json'
require 'addressable/uri'

class Status < ActiveRecord::Base
  # validates :text, :twitter_status_id, :twitter_user_id, :presence => true

  def self.fetch_by_twitter_user_id!(user_id)
    TwitterSession.get("statuses/user_timeline", {:user_id => user_id})
  end

  def self.parse_json(fetched_timeline)

    fetched_timeline.each do |status|
      txt = status["text"]
      user_id = status["user"]["id"]
      status_id = status["id_str"]

      p Status.new(txt, status_id, user_id).save!
    end
  end

  def initialize(txt, status_id, user_id)
    @txt = txt
    @status_id = status_id
    @user_id = user_id
  end

end
