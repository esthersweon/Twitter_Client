require 'addressable/uri'
require 'json'
require 'yaml'
require 'oauth'
require 'launchy'

class TwitterSession
  CONSUMER_KEY = "i50GOFLLHTTixmk7B1z9gMHG7"
  CONSUMER_SECRET = "gFD1Uld4ia5RIrP97ek37jm2KoxawcV0cuEUG1fvbCI8tl8pOc"

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  # Both `::get` and `::post` should return the parsed JSON body.
  def self.get(path, query_values)
    response = access_token.get(path_to_url(path, query_values)).body
    results = JSON.parse(response)
  end

  def self.post(path, req_params)
    response = access_token.post(path_to_url(path, req_params)).body
    results = JSON.parse(response)
  end

  def self.access_token
    # Load from file or request from Twitter as necessary. Store token
    # in class instance variable so it is not repeatedly re-read from disk
    # unnecessarily.
    # We can serialize token to a file, so that future requests don't
    # need to be reauthorized.
    @TOKEN_FILE = "access_token.yml"
    if File.exist?(@TOKEN_FILE)
      # reload token from file
      YAML.load(File.read(@TOKEN_FILE))
    else
      # copy the old code that requested the access token into a
      # `request_access_token` method.
      access_token = request_access_token
      File.open(@TOKEN_FILE, "w") { |f| YAML.dump(access_token, f) }
    end
  end

  def self.request_access_token
    # Put user through authorization flow; save access token to file

    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url

    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)

    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp
    access_token = request_token.get_access_token(
      :oauth_verifier => oauth_verifier
    )
  end

  def self.path_to_url(path, query_values = nil)
    # All Twitter API calls are of the format
    # "https://api.twitter.com/1.1/#{path}.json". Use
    # `Addressable::URI` to build the full URL from just the
    # meaningful part of the path (`statuses/user_timeline`)

    Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/#{path}.json",
      :query_values => query_values
    ).to_s
  end
end

# TwitterSession.get(
#   "statuses/user_timeline",
#   { :user_id => "973274587" }
# )
# TwitterSession.post(
#   "statuses/update",
#   { :status => "New Status!" }
# )