class NaverTagsGetter
  require 'selenium-webdriver'
  require 'csv'

  INITIAL_URL = 'https://matome.naver.jp/keyword/'.freeze

  attr_accessor :driver

  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(timeout: 10)

    @tag_strs = []

    @driver.get INITIAL_URL
  end

  def exec
    pp '取得開始'
    take_tag_strs
    output_tag_strs
    pp '取得終了'
  end

  # private

  def take_tag_strs
    pages = index_pages

    (1..pages).each do |i|
      @driver.get (INITIAL_URL + "?page=#{i}")
      @tag_strs += @driver.find_elements(:xpath, "//ul[@class='mdKWList01Ul']/li/a").map(&:text)

      sleep 1
    end
  end

  def output_tag_strs
    File.open('./naver_tags.csv', 'w', encoding: 'cp932', undef: :replace, replace: '*') do |csv|
      csv = CSV.new(csv, encoding: 'cp932')
      @tag_strs.each do |tag_str|
        csv << [tag_str]
      end
    end
  end

  def index_pages
    @driver.get INITIAL_URL

    @driver.find_elements(:xpath, "//div[@class='MdPagination04']/a").last.text.to_i
  end
end
