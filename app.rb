require 'httparty'
require 'open-uri'
require 'pathname'
require 'nokogiri'

class Rget

  attr_accessor :images, :csss, :doc, :url

  def initialize( url )
    base_url = URI.parse( url )
    @base_url = base_url.scheme + '://' + base_url.host
    @url = url 
    @doc = doc
  end

  def doc
    Nokogiri::HTML(open( @url ))
  end

  def csss
    @doc.css('[rel="stylesheet"]').map do |l| 
      l['href']
    end
  end

  def images
    @doc.css('img').map do |img| 
      src = @base_url + img['src']
      filename = Pathname.new( src ).basename.to_s
      p filename
      img['src']
    end
  end

end

url = 'http://www.tacobell.com/home'
r = Rget.new( url )
r.images