#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://boxrec.com/"

division = "Welterweight"

search_url = "http://boxrec.com/ratings.php?sex=M&division=#{division}&pageID="

path='//*[@id="mainContent"]/table/tr[position()>2]'

boxers = CSV.open("csv/boxers.csv","w")

(1..69).each do |page|

  url = search_url+page.to_s

  begin
    page = agent.get(url)
  rescue
    print "  -> error, retrying\n"
    retry
  end

  page.parser.xpath(path).each do |tr|
    row = [division]
    tr.xpath("td").each_with_index do |td,j|
      case j
      when 0,11
        next
      when 2
        text = td.text.strip
        a = td.xpath("a").first
        href = base+a.attributes["href"].value.strip
        human_id = href.split("=")[1].split("&")[0]
        cat = href.split("=")[2]
        row += [human_id, cat, text, href]
      when 4
        text = td.text.strip
        record = text.split("-")
        wins = record[0]
        wko = wins.split("(")[1].split(")")[0] rescue 0
        wins = wins.split("(")[0]
        losses = record[1]
        lko = losses.split("(")[1].split(")")[0] rescue 0
        losses = losses.split("(")[0]
        draws = record[2]
        row += [wins, wko, losses, lko, draws, text]
      when 5
        last6 = []
        td.xpath("table/tr/td").each do |td2|
          outcome = td2.attributes["class"].value.strip rescue nil
          last6 += [outcome]
        end
        last6 = last6.to_s.gsub("[","{").gsub("]","}")
        row += [last6]
      when 9
        div = td.xpath("div").first
        flag = div.attributes["class"].value.strip rescue nil
        title = div.attributes["title"].value.strip rescue nil
        row += [flag,title]
      else
        text = td.text.strip
        row += [text]
      end
    end
    if (row.size>2)
      boxers << row
    end
  end
  boxers.flush

end

boxers.close
