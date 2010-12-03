# encoding: utf-8

require 'socket'
require 'uri'
require 'zlib'
require 'stringio'

#
# License:	Under the Ruby license and the GPL2
#	Author: Shihua Ma
# Email:	mashihua@gmail.com
# Web site:	http://www.f2eskills.com
#

class ChunkedView
  
  def initialize
    @version = @code = @message = nil
  end
  
  #HTTP version
  attr_reader :version
  #HTTP code
  attr_reader :code
  #HTTP message
  attr_reader :message
  #HTTP headers
  attr_reader :headers
  #HTTP body
  attr_reader :body
  #HTTP chunckd
  attr_reader :chunk

  def get url, deflate = nil , head = nil
    @headers = {}
    @body = []
    @chunk = []
    uri = URI.parse(url)
    path = (uri.path == "" ? "/" : uri.path) + (uri.query ? "?" + uri.query : "")
    
    if head
      request = head
    else
      request = "GET #{path} HTTP/1.1\r\n"
      request << "Host: #{uri.host}\r\n"
      request << "User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6;) Gecko/20101026 Firefox/3.6.12\r\n"
      request << "Accept: */*\r\n"
      request << "Accept-Encoding: gzip,deflate\r\n" if deflate
      request << "\r\n"
    end
    
    socket = TCPSocket.open(uri.host,uri.port)
    socket.print(request)
    
    str = socket.readline.chomp
    m = /^HTTP(?:\/(\d+\.\d+))?\s+(\d\d\d)\s*(.*)$/in.match(str)
    @version,@code,@message = m.captures
    
    until "" == (str = socket.readline.chomp)
      http_header str
    end
    
    body_read socket
    
  end
  
  def chunked?
    return false unless @headers['transfer-encoding']
    (/(?:^|[^\-\w])chunked(?![\-\w])/i =~ @headers['transfer-encoding']) ? true : false
  end
  
  def deflate?
    return false unless @headers['content-encoding']
    ["deflate", "gzip"].include?(@headers["content-encoding"])
  end
  
  private
  def http_header line
    m = /^([^:]+):(\s*)/.match(line)
    @headers[m[1].downcase] = m.post_match.strip
  end
  
  def length
      return nil unless @headers['content-length']
      len = @headers['content-length'].slice(/\d+/)
      len.to_i
  end
  
  def body_read socket
    
    if chunked?
      chunck_read socket
      return
    end
    
    if deflate?
      len = length
      str = ""
      if len
        str = socket.read len        
      else
        str = socket.read
      end
      @chunk << str
      @body << decompress(str)
    else
      @body << socket.read
    end
    
  end
  
  def chunck_read socket
      len = str = nil
      total = 0
      arr = []
      while true
        str = socket.readline
        #chunck length
        len = str.slice(/[0-9a-fA-F]+/).hex
        break if len == 0
        #read chunck
        str = socket.read len
        #deflate?
        if deflate?
					chunk = @chunk.join('') + str
          @chunk << chunk
          @body <<  decompress(chunk)
        else
          arr << str 
          @body <<  arr.join('')
        end
        total += len
        #strip \r\n
        socket.read 2
      end
  end
  
  def decompress str
    if ["gzip"].include?(@headers["content-encoding"])
      zlib =  Zlib::GzipReader.new(StringIO.new(str))
      buffer = ""
      begin
        zlib.each_byte{|b|
          buffer << b
        }
      rescue Zlib::GzipFile::Error
      end
      return buffer
    end
    if ["deflate"].include?(@headers["content-encoding"])
      zstream = Zlib::Inflate.new(-Zlib::MAX_WBITS)
      str = zstream.inflate(str)
      zstream.finish
      zstream.close
    end
    str
  end
 
end


