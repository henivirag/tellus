require 'net/http'
require 'json'

class ClassGiphy
  # Example URL: "https://api.giphy.com/v1/gifs/search?api_key=7gx4tjMPahEr7JlzIUTklF4teMILZG9C&q=friends&limit=1"

  # Send a request to https://giphy.com/ and returns the response.
  #
  # @param search_string [String] the word/phrase to search for. Required param.
  # @param limit [Integer] the max number of gifs to return. Optional param.
  # @param offset [Integer] the offset value for the request. Optional param.
  #
  # @return results_hash [JSON] the response as a hash.
  def send_request(search_string: , limit: nil, offset: nil)
    url = construct_url(search_query: search_string, limit: limit, offset: offset)
    results_hash = nil

    unless url.nil?
      response = Net::HTTP.get_response(URI.parse(url))
      response_body = response.body
      results_hash = JSON.parse(response_body)
    end

    return results_hash
  end

  private

  # Constructs and returns a URL.
  #
  # @param search_query [String] the word/phrase to search for. Required param.
  # @param limit [Integer] the max number of gifs to return. Optional param.
  # @param offset [Integer] the offset value for the request. Optional param.
  #
  # @return url [String] the constructed URL.
  def construct_url(search_query: nil, limit: nil, offset: nil)
    endpoint = "https://api.giphy.com/v1/gifs/search"
    api_key = "7gx4tjMPahEr7JlzIUTklF4teMILZG9C" # generated on a newly created personal account

    url = "#{endpoint}"
    url += "?q=#{search_query}" unless search_query.nil?
    url += "&api_key=#{api_key}"
    url += "&limit=#{limit}" unless limit.nil?
    url += "&offset=#{offset}" unless offset.nil? # offset-based pagination

    return url
  end
end