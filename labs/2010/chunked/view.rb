require 'zlib'
require 'stringio'

def decompress str
	value = ""
	zlib =  Zlib::GzipReader.new(StringIO.new(str))
	begin
		zlib.each_byte{|b|
			value << b
		}
	rescue Zlib::GzipFile::Error
	end
	if value == ""
	  zstream = Zlib::Inflate.new(-Zlib::MAX_WBITS)
	  value = zstream.inflate(str)
	  zstream.finish
	  zstream.close
	end
	puts value
end

def main(arg)
    if 1 > arg.length
      puts "ruby view.rb filename"
    else
      f = File.open(arg[0],"rb").read
      decompress f
    end
end

main(ARGV)