#!/usr/bin/ruby
# USE: ./JPEG_SCRIPT.RB [GIF_FILE]

#magic header

#base64 encode
data = [File.open("#{ARGV[0]}", "rb").read].pack("m")

#write to file
File.open('result','w'){|i| i.write("#{data.gsub(/\n/,'')}")}
