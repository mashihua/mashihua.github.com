require "thunkedview"

c = ChunkedView.new
c.get "http://www.taobao.com/",true
i = 0
#only for 302 etc.
while(c.code.to_i != 200)
  c.get c.headers['location'],true 
  break if i == 3
  i += 3
end

puts "Response code: #{c.code}"
puts "Response chuncked length: #{c.chunk.length}"
puts "Response html length: #{c.body.join('').length}"
puts "Compressed html length: #{c.chunk.join('').length}"
puts "Response headers:"
c.headers.each{|k,v|
  puts "\t#{k}: #{v}"
}

#display html
c.body.each{|k|
  #print k
}

#write chunck to file
i = 1
c.chunk.each{|k|
  #File.open("chunked.#{i}.gz","wb"){|f| f.print k}
  #i += 1
}