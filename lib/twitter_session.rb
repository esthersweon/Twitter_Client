require 'addressable/uri'
require 'json'
require 'yaml'
require 'oauth'
require 'launchy'

class TwitterSession
  CONSUMER_KEY = "i50GOFLLHTTixmk7B1z9gMHG7"
  CONSUMER_SECRET = "gFD1Uld4ia5RIrP97ek37jm2KoxawcV0cuEUG1fvbCI8tl8pOc"

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, site: "https://twitter.com")

  TOKEN_FILE_NAME = "access_token.yml"

  def self.access_token
    return @access_token unless @access_token.nil?
    if File.exist?(TOKEN_FILE_NAME)
      @access_token = File.open(TOKEN_FILE_NAME) { |f| YAML.load(f) }
    else
      @access_token = request_access_token
      File.open(TOKEN_FILE_NAME, "w") { |f| YAML.dump(@access_token, f) }
      @access_token
    end
  end

  def self.request_access_token
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    Launchy.open(authorize_url)

    puts "Log in, and type in the verification code."
    oauth_verifier = gets.chomp
    access_token = request_token.get_access_token(oauth_verifier: oauth_verifier)
    access_token
  end

  # All Twitter API calls have "https://api.twitter.com/1.1/#{path}.json" format
  # Varies only with path
  def self.path_as_url(path, query_values = nil)
    Addressable::URI.new(
      scheme: "https",
      host: "api.twitter.com",
      path: "1.1/#{path}.json",
      query_values: query_values
    ).to_s
  end

  def self.get(path, query_values)
    url = path_as_url(path, query_values)
    response = access_token.get(url).body
    results = JSON.parse(response)
  end

  def self.post(path, req_params)
    url = path_as_url(path, req_params)
    response = access_token.post(url).body
    results = JSON.parse(response)
  end
end