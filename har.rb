# filename: har.rb

require 'rubygems'
require 'bundler/setup'
require 'selenium-webdriver'
require 'browsermob/proxy'
require './convert.rb'

puts "Please enter the test file name: "
input = gets.chomp

def configure_proxy
  proxy_binary = BrowserMob::Proxy::Server.new('./browsermob-proxy-2.1.4/bin/browsermob-proxy')
  proxy_binary.start
  proxy_binary.create_proxy
end

def browser_profile
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile.proxy = @proxy.selenium_proxy
  profile
end

def teardown
  @driver.quit
  @proxy.close
end

def capture_traffic
  @proxy.new_har
  yield
  @proxy.har
end

def run
  setup
  @har = capture_traffic { yield }
  teardown
end

def setup
  @proxy = configure_proxy
  @driver = Selenium::WebDriver.for :firefox, profile: browser_profile
end

run do
  load "selenium_test_files/" + input
end

@har.save_to './selenium.har'

HARtoJMX.convert 'selenium.har'
# the default filename output is `jmeter.jmx`


