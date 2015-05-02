#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://boxrec.com/"

#path='//*[@id="mainContent"]/table/tr[position()>2]'

path = '//table[@align="center"]/tr[position()>1]'

division = ARGV[0]

boxers = CSV.open("csv/boxers_#{division}.csv","r")
fights = CSV.open("csv/fights_#{division}.csv","w")

boxers.each_with_index do |boxer,i|

  found = 0

  division = boxer[0]
  human_id = boxer[2]
  name = boxer[4]
  url = boxer[5]+"&set_bout_ratings=On"
  
  won = boxer[7].to_i
  lost = boxer[9].to_i
  drew = boxer[11].to_i

  total = won+lost+drew

  print "#{i} - #{name}"

  begin
    page = agent.get(url)
  rescue
    print "  -> error, retrying\n"
    retry
  end

  page.parser.xpath(path).each_with_index do |tr,j|

    row = [division, human_id, name]
    tr.xpath("td").each_with_index do |td,k|

      case k
      when 0,1,18
        next
      when 2
        text = td.text.strip
        a = td.xpath("a").first
        href = base+a.attributes["href"].value.strip rescue nil
        row += [text, href]
      when 3
        a = td.xpath("a").first
        href = base+a.attributes["href"].value.strip rescue nil
        row += [href]
      when 4
        text = td.text.strip
        a = td.xpath("a").first
        href = base+a.attributes["href"].value.strip rescue nil
        opponent_id = href.split("=")[1].split("&")[0] rescue nil
        ocat = href.split("=")[2] rescue nil
        row += [opponent_id, ocat, text, href]
      when 5
        text = td.text.strip
        orecord = text.split("-") rescue nil
        owins = orecord[0]
        owins = owins.split("(")[0] rescue nil
        olosses = orecord[1]
        olosses = olosses.split("(")[0] rescue nil
        odraws = orecord[2]
        row += [owins, olosses, odraws, text]
      when 6
        olast6 = []
        td.xpath("table/tr/td").each do |td2|
          outcome = td2.attributes["class"].value.strip rescue nil
          olast6 += [outcome]
        end
        olast6 = olast6.to_s.gsub("[","{").gsub("]","}")
        row += [olast6]
      when 17
        a = td.xpath("a").first
        href = base+a.attributes["href"].value.strip rescue nil
        row += [href]
      else
        text = td.text.strip
        row += [text]
      end

    end
    if (row.size>20)
      fights << row
      found += 1
    end
  end
  fights.flush
  print " - found #{found}/#{total}\n"

end

fights.close
