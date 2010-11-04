#!/usr/bin/ruby
# CONVERT INCORRECTLY TRANSFER DATA. USE GIMP INSTEAD
# USE: ./GIF_SCRIPT.RB [GIF_FILE]

# OPEN GIF FILE IN HEX
orig=File.open("#{ARGV[0]}",'rb'){|f| f.read.unpack("H*")}.to_s

# FUTURE HEADER,SIZE IS 13.
header=orig[0..25]

#DETERMINE WHETHER IT IS A ANIMATED GIF
#ANIMATED GIF HAVE APPLICATION EXTENSION AND NETSCAPE2.0 MARKER
if orig[/21ff0b4e45545343415045322e30/]
	raise RuntimeError,"This program does not support animated GIF!"
end

# GREP GENERAL COLOR TABLE
# [26..1565]/6 = 256 BYTE (MAX SIZE OF COLOR TABLE)
color_table=orig[26..1565][/(.*)21fe/,1]

#FOR IM's COMMAND "convert jpeg gif" WHICH ADD GRAPHIC CONTROL EXTENSION.
if color_table.class == NilClass
   color_table=orig[26..1581][/(.*)21f9/,1]
end

#UP TO IMAGE DESCRIPTOR
if color_table.class == NilClass
   color_table=orig[26..1575][/(.*?)2c0000/,1]
end



#FOR DEBUG,puts color_table.length
#puts "COLORS IN PALLETE: #{color_table.length/6}"

# GIF IMAGE DATA
#data=orig[/00(2c0000.*)/,1]
data=orig[/2c0000.*/]

# SAVE 11 BYTE'S INFO AND ADOPT IT FOR LOCAL COLOR TABLE
# Global Color Table Flag       1 Bit
#	Color Resolution              3 Bits
#	Sort Flag                     1 Bit
#	Size of Global Color Table    3 Bits

#Local Color Table Flag        1 Bit
#	Interlace Flag                1 Bit
#	Sort Flag                     1 Bit
#	Reserved                      2 Bits
#	Size of Local Color Table     3 Bits

eleven=header[20..21].to_i(16).to_s(2)
local_mix="10#{eleven.split("")[4].to_s}00#{eleven.split("")[5..7].to_s}".to_i(2).to_s(16)

# 11 BYTE TO ZERO
header[20..21]="00"
# DECLARE LOCAL COLOR TABLE
data[18..19]=local_mix

#MAGIC HEADER
head = ";msh;background-image:url(data:image/gif;base64,"

#FOR DEBUG
#require 'base64'
#var = header + "21fe313030" + Base64.decode64(head).unpack("H*").to_s
#var << header + "21fe013000" + data[0..19] + color_table + data[20..-1]
#File.open('out.gif','wb'){|f| f.write(var.to_a.pack("H*"))}

#OUT GIF
out = [header + "21fe313030"].pack("H*")
#INNER GIF 
inner = [header + "21fe013000" + data[0..19] + color_table + data[20..-1] ].pack("H*")
#ALL DATA IN ONE STRING
base = [out].pack("m") + head  + [inner].pack("m")

# JUST PASTE TEXT FROM THIS FILE TO CSS
File.open('out_gif64','w'){|s| s.write("#{base.gsub(/\n/,'')}\);")}
