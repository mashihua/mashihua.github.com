#!/usr/bin/ruby
# USE: ./JPEG_SCRIPT.RB [GIF_FILE]

#magic header
header="/9j/4AA0;background-image:url(data:image/jpeg;base64;00,"

#base64 encode
data = [File.open("#{ARGV[0]}", "rb").read].pack("m")

#write to file
File.open('out_jpeg64','w'){|i| i.write("#{header}#{data.gsub(/\n/,'')}\);")}
