require 'minitest/autorun'
require_relative 'giphy'

class ClassTestGiphy < Minitest::Unit::TestCase
  def setup
    super
    @giphy = ClassGiphy.new
  end

  # verify 200 response code and 'OK' response message
  def test_successful_request
    resp = @giphy.send_request(search_string: "friends")

    verify_response_code(resp: resp)
    verify_response_message(resp: resp)
  end

  # verify nil response when no query string is specified in the request
  def test_no_query_string
    resp = @giphy.send_request(search_string: nil)

    assert_nil(resp['data'])
  end

  # verify that data type is 'gif'
  def test_data_type
    resp = @giphy.send_request(search_string: "friends", limit: 1)

    verify_data_type(resp: resp)
  end

  # verify that the number of returned gifs matches the specified limit (3)
  def test_pos_request_limit
    expected_num_of_gifs = 3
    resp = @giphy.send_request(search_string: "friends", limit: expected_num_of_gifs)

    actual_num_of_gifs = resp['data'].length
    err_msg = "Expected #{expected_num_of_gifs} gifs to be returned but got #{actual_num_of_gifs} instead!"
    assert_equal(expected_num_of_gifs, actual_num_of_gifs, err_msg)
  end

  # verify that the number of returned gifs matches the specified limit (0)
  def test_request_limit_zero
    expected_num_of_gifs = 0
    resp = @giphy.send_request(search_string: "friends", limit: expected_num_of_gifs)

    actual_num_of_gifs = resp['data'].length
    err_msg = "Expected #{expected_num_of_gifs} gifs to be returned but got #{actual_num_of_gifs} instead!"
    assert_equal(expected_num_of_gifs, actual_num_of_gifs, err_msg)
  end

  # verify that the number of returned gifs matches the specified limit (0)
  def test_neg_request_limit
    resp = @giphy.send_request(search_string: "friends", limit: -1)

    actual_num_of_gifs = resp['data'].length
    err_msg = "Expected #{0} gifs to be returned but got #{actual_num_of_gifs} instead!"
    assert_equal(0, actual_num_of_gifs, err_msg)
  end

  # verify that two requests with default offset 0 and the same limit return the same results
  def test_request_offset_0_same_lim
    resp_1 = @giphy.send_request(search_string: "friends", limit: 1, offset: 0)
    url_1 = resp_1['data'][0]['url']

    resp_2 = @giphy.send_request(search_string: "friends", limit: 1, offset: 0)
    url_2 = resp_2['data'][0]['url']

    err_msg = "Expected to retrieve the same gif in both requests but got \n\t#{url_1} and\n\t#{url_2} instead!"
    assert_equal(url_1, url_2, err_msg)
  end

  # verify that when two requests are sent such that:
  #   [1] the two requests specify different limits, and
  #   [2] both requests specify default offset 0
  # the resulting gifs of the request with the LOWER limit will be a subset of the other one
  def test_request_offset_0_diff_lim
    resp_1 = @giphy.send_request(search_string: "friends", limit: 1, offset: 0)
    urls_1 = list_of_urls(response_body: resp_1['data'])

    resp_2 = @giphy.send_request(search_string: "friends", limit: 2, offset: 0)
    urls_2 = list_of_urls(response_body: resp_2['data'])

    refute_equal(urls_1.length, urls_2.length, "Expected the resulting lists to have diff lengths!")
    assert_includes(urls_2, urls_1[0],"Expected #{urls_1} to be a subset of #{urls_2}!")
  end

  # when two requests are sent with the same limit such that:
  #   [1] the first one uses the default offset value 0, and
  #   [2] the second one specifies offset 2
  # the last gif of request #1 should be the same as the first gif of request #2
  def test_request_offset_2
    # should get first 3 items, starting at the default position 0
    resp_1 = @giphy.send_request(search_string: "friends", limit: 3)
    # puts "\nRequest [1]\n[1] - #{resp_1['data'][0]['url']}\n[2] - #{resp_1['data'][1]['url']}\n[3] - #{resp_1['data'][2]['url']}\n"
    last_of_req_1 = resp_1['data'][2]['url']

    # should also get 3 items, starting 2 positions away from the start (default=0)
    resp_2 = @giphy.send_request(search_string: "friends", limit: 3, offset: 2)
    # puts "\nRequest [2]\n[1] - #{resp_2['data'][0]['url']}\n[2] - #{resp_2['data'][1]['url']}\n[3] - #{resp_2['data'][2]['url']}\n"
    first_of_req_2 = resp_2['data'][0]['url']

    assert_equal(last_of_req_1, first_of_req_2,  err_msg = "Expected #{last_of_req_1} to be the same as #{first_of_req_2}!")
  end

  # when two requests are sent with the same limit such that:
  #   [1] the first one uses the default offset value 0, and
  #   [2] the second one sets the offset value to the same value as the limit
  # the results of the two requests should not contain any elements in common.
  def test_request_offset_3
    # should get first 3 items, starting at the default position 0
    resp_1 = @giphy.send_request(search_string: "friends", limit: 3, offset: 0)
    # puts "\nRequest [1]\n[1] - #{resp_1['data'][0]['url']}\n[2] - #{resp_1['data'][1]['url']}\n[3] - #{resp_1['data'][2]['url']}\n"
    urls_1 = list_of_urls(response_body: resp_1['data'])

    # should also get 3 items, starting 3 positions away from the start (default=0)
    resp_2 = @giphy.send_request(search_string: "friends", limit: 3, offset: 3)
    # puts "\nRequest [2]\n[1] - #{resp_2['data'][0]['url']}\n[2] - #{resp_2['data'][1]['url']}\n[3] - #{resp_2['data'][2]['url']}\n"
    urls_2 = list_of_urls(response_body: resp_2['data'])

    err_msg = "Expected same number of results to be returned but got #{urls_1.length} and #{urls_2.length}, respectively!"
    assert_equal(urls_1.length, urls_2.length, err_msg)

    # there should be no elements in common between the two list results
    urls_2.each do |url|
      refute_includes(urls_1, url)
    end

    # obvious, given that this is the result of the request with offset=0
    urls_1.each do |url|
      refute_includes(urls_2, url)
    end
  end

  private

  def verify_response_code(resp: )
    resp_code = resp['meta']['status']
    assert_equal(200, resp_code, "Expected response code 200 but got #{resp_code} instead!")
  end

  def verify_response_message(resp: )
    resp_msg = resp['meta']['msg']
    assert_equal("OK", resp_msg, "Expected response msg 'OK' but got #{resp_msg} instead!")
  end

  def verify_data_type(resp:)
    resp['data'].each do |gif|
      data_type = gif['type']
      assert_equal("gif", data_type, "Expected data type 'gif' but got #{data_type} instead!")
    end
  end

  def list_of_urls(response_body: )
    urls = []
    response_body.each do |gif|
      urls.push(gif['url'])
    end
    return urls
  end

  # used for debugging purposes only
  # def print_data_info(body:)
  #   body.each do |key, value|
  #     puts "\n--- #{key} = #{value}\n"
  #   end
  # end
end