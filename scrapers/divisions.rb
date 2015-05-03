#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://boxrec.com/"

url = "http://boxrec.com/ratings.php"

path='//*[@id="division"]/option[position()>1]'

divisions = CSV.open("csv/divisions.csv","w")

begin
  page = agent.get(url)
rescue
  print "  -> error, retrying\n"
  retry
end

page.parser.xpath(path).each do |option|
  value = option.attributes["value"].value
  division = value.gsub(" ","+")
  divisions << [division, value]
end

divisions.close
