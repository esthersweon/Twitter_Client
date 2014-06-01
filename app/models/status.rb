# == Schema Information
#
# Table name: statuses
#
#  id                :integer          not null, primary key
#  text              :string(140)
#  twitter_status_id :string(255)
#  twitter_user_id   :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

require 'twitter_session'
require 'launchy'
require 'json'
require 'addressable/uri'
require 'open-uri'

def internet_connection?
  begin
    true if open("http://www.google.com/")
  rescue => error
    puts error
    false
  end
end

class Status < ActiveRecord::Base
  validates :text, :twitter_status_id, :twitter_user_id, presence: true
  validates :twitter_status_id, uniqueness: true

  attr_accessor :text, :twitter_status_id, :twitter_user_id

  belongs_to :user, 
  class_name: "User", 
  foreign_key: :twitter_user_id, 
  primary_key: :twitter_user_id

  def self.get_by_twitter_user_id(twitter_user_id)
    if internet_connection?
      fetch_by_twitter_user_id!(twitter_user_id)
    end

    Status.where({twitter_user_id: twitter_user_id})
  end

  def self.fetch_by_twitter_user_id!(twitter_user_id)
    fetched_statuses_params = TwitterSession.get("statuses/user_timeline", {user_id: twitter_user_id})
    
    fetched_statuses = fetched_statuses_params.map do |status_params|
      parse_json(status_params)
    end

    old_twitter_status_ids = 
    Status.where({twitter_user_id: twitter_user_id}).pluck(:twitter_status_id)

    unsaved_statuses = []

    fetched_statuses.each do |status|
      next if old_twitter_status_ids.include?(status.twitter_status_id)
      status.save!

      unsaved_statuses << status
    end

    unsaved_statuses
  end

  def self.parse_json(status_params)
    Status.new(
      text: status_params["text"], 
      twitter_status_id: status_params["id_str"], 
      twitter_user_id: status_params["user"]["id_str"]
    )
  end

  def self.post(text)
    new_status_params = TwitterSession.post("statuses/update", {status: text})
    Status.parse_json(new_status_params).save!
  end

end
