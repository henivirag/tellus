require "selenium-webdriver"
require 'webdrivers'
require 'minitest/autorun'

class ClassScenarios < Minitest::Unit::TestCase
  def setup
    super

    @browser = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(:timeout => 3)
    @search_str = "friends"
  end

  def test_search_field_is_displayed
    @browser.navigate.to("https://giphy.com/")

    @wait.until {
      search_bar = @browser.find_element(:xpath, "/html/body/div[4]/div/div/div[3]/div[2]/div")
      assert_equal(true, search_bar.displayed?, "Expected search field to be displayed!")
      assert_equal(true, search_bar.enabled?, "Expected search field to be enabled!")
    }

    @browser.quit
    puts "Test #1 --> Search field is displayed and enabled - as expected"
  end

  def test_search_button_is_displayed
    @browser.navigate.to("https://giphy.com/")

    @wait.until {
      search_button = @browser.find_element(:xpath, "/html/body/div[4]/div/div/div[3]/div[2]/div/div/a")
      assert_equal(true, search_button.displayed?, "Expected search field to be displayed!")
      assert_equal(true, search_button.enabled?, "Expected search field to be enabled!")
    }

    @browser.quit
    puts "Test #2 --> Search button is displayed and enabled - as expected"
  end

  def test_can_populate_search_field
    @browser.navigate.to("https://giphy.com/")

    input = @wait.until {
      element = @browser.find_element(:xpath, "/html/body/div[4]/div/div/div[3]/div[2]/div/div/div/form/input")
      assert_equal(true, element.displayed?, "Expected search field to be displayed!")
      assert_equal(true, element.enabled?, "Expected search field to be enabled!")
      assert_equal("", element['value'], "Search field should be empty!")

      if element.nil?
        puts "Element not found!"
        @browser.quit
        return
      else
        element
      end
    }
    input.send_keys(@search_str)
    sleep(1) # for visual confirmation in the browser

    refute_equal( "", input['value'], "Search field should not be empty!")
    assert_equal(@search_str, input['value'], "Search value should be '#{@search_str}, not #{input['value']}'!")

    @browser.quit
    puts "Test #3 --> Search field was populated with search string '#{@search_str}' - as expected"
  end

  # NOTE - commented test case
  def test_search_button_works
    @browser.navigate.to("https://giphy.com/")

    # get search field
    input = @wait.until {
      element = @browser.find_element(:xpath, "/html/body/div[4]/div/div/div[3]/div[2]/div/div/div/form/input")

      if element.nil?
        puts "Element not found!"
        @browser.quit
        return
      else
        element
      end
    }
    # search for the input string '@search_str'
    input.send_keys(@search_str)
    sleep(1) # for visual confirmation in the browser

    # verify that the page content includes the 'Trending' section
    # indicates that we're on the home page before the search takes place
    page_content_before_search = @browser.find_element(:xpath, "/html/body/div[4]/div[1]/div/div[5]").text
    assert_includes(page_content_before_search, "Trending")
    refute_includes(page_content_before_search, @search_str)

    # click the search button
    button = @browser.find_element(:xpath, "/html/body/div[4]/div[1]/div/div[3]/div[2]/div/div/a")
    button.click

    # verify that the page content now includes a section called 'friends' (which is the value of '@search_str')
    # partially indicates that the search was carried out successfully
    page_content_after_search = @browser.find_element(:xpath, "/html/body/div[4]/div[1]/div/div[5]").text
    assert_includes(page_content_after_search, @search_str)
    refute_includes(page_content_after_search, "Trending")

    # verify that the title includes the search string 'friends'
    title = @browser.find_element(:xpath, "/html/body/div[4]/div[1]/div/div[5]/div[1]/div[1]/h1").text
    assert_includes("#{title}", @search_str , "Title under search bar should have included '#{@search_str}'!")

    # get the results for the 'GIPHY Clips' section on the page
    giphy_clips_results = @wait.until {
      giphy_clips_results = @browser.find_element(:xpath, "/html/body/div[4]/div[1]/div/div[5]/div[2]/div/div[2]/div")

      giphy_clips_results
    }

    # get the list of GIPHY Clips and verify that we found some, ie: the result isn't empty
    @wait.until {
      giphy_clips = giphy_clips_results.find_elements(:xpath, "./div")

      refute_empty(giphy_clips, "GIPHY Clips element should not be empty!")
      refute_equal(0, giphy_clips.length, "Expected the number of GIPHY Clips to be > 0!")
    }

    # close the browser window
    @browser.quit
    puts "Test #4 --> Search button works - as expected"
  end
end