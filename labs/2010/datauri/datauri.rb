#!/usr/bin/ruby
require "ftools"

#png path
path =  "./png/"
incl = ARGV[0] ? ARGV[0] : '.png'
h = {}
h.store('origin',"");
h.store('decompress',"");

if File::directory?( path ) 
	Dir.entries( path ).map{ |entry|
		if entry.include? incl
			#copy file
			File.copy("#{path}#{entry}","#{path}decompress-#{entry}")
			#decompress png file
			system "pngout /s4 /force #{path}decompress-#{entry} > /dev/null 2>&1"
			#selector
			selector = entry.gsub(/(png$|\.)/,'')
			#append new base64's image
			h.each {|key,css|
				name = key.eql?('origin') ? '' : key + "-"
				#base64 string
				data = [File.open("#{path}#{name}#{entry}", "rb") {|io| io.read}].pack("m").gsub(/[\r\n]/,'')
				h.store(key,css << "#{selector} {background-image: url('data:image/png;base64,#{data}');}\n");
			}
		end
	}
end

#write and gzip files
h.each {|key,css|
	file = File.new("#{key}.css", 'w');
	file.puts css
	file.close
	system "gzip -9 #{key}.css"
}

