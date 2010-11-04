#!/usr/bin/ruby
# USE: ./PNG_SCRIPT.RB [PNG_FILE]
require 'zlib'
require 'base64'

# OPEN GIF FILE IN HEX
orig=File.open("#{ARGV[0]}",'rb'){|f| f.read.unpack("H*")}.to_s

#FOR PERFORMANCE REASON,WE ONLY NEED IHDR,PLTE,tRNS,IDAT,IEND CHUNK
#GET FILE HEADER AND IHDR
length = orig[16..23].hex.to_i * 2 + 16 + 23
ihdr=orig[0..length]

#PLTE CHUNK - 504c5445
if orig[/504c5445/].class == NilClass
	plte = ""
else
	#CHUNK LENGTH
	leng_str = orig[/(.{8})504c5445/,1]
	plte = leng_str + orig[orig.index(/504c5445/), leng_str.hex.to_i  * 2 + 16]
end

#tRNS CHUNK - 74524e53
if orig[/74524e53/].class == NilClass
	trns = ""
else
	#CHUNK LENGTH
	leng_str = orig[/(.{8})74524e53/,1]
	trns = leng_str + orig[orig.index(/74524e53/), leng_str.hex.to_i  * 2 + 16]
end

#IDAT - 49444154
data=orig[/.{8}49444154.*/]

#MAGIC HEADER
header = ";msh;background-image:url(data:image/png;base64,"
#MAGIC COMMENT
comment =  Base64.decode64(header)

###### OUTER PNG
# "00000059"+"74455874"+"436f6d6d656e7400"
# tEXt_length + 'tEXt' + 'Comment.'
# "3030" - two zero for base64 balance
###### INNER PNG
# "00000008"+"74455874"+"436f6d6d656e7400"
# min_tEXt_length + 'tEXt' + 'Comment.' + CRC

#FOR CHUNK CRC
text = "74455874"
thunk = "436f6d6d656e7400" + "3030" + comment.unpack("H*").to_s + ihdr + "00000008" + "74455874" + "436f6d6d656e7400"
crc = Zlib.crc32((text + thunk).to_a.pack("H*"), 0).to_s(16)

var = ihdr + "00000059" + text + thunk + crc +plte + trns+data

#FOR DEBUG
File.open('out.png','wb'){|f| f.write(var.to_a.pack("H*"))}

#ALL DATA IN ONE STRING
base = [var.to_a.pack("H*")].pack("m").gsub(/mshbackgroundimageurldataimage\/pngbase64/,header)

# JUST PASTE TEXT FROM THIS FILE TO CSS
File.open('out_png64','w'){|s| s.write("#{base.gsub(/\n/,'')}\);")}
