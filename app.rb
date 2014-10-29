require 'httparty'
require 'open-uri'
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
      img.attributes['src'].value = 'data:image/jpeg;base64,' + Base64.encode64(open(src).read)
    end
    File.open( 'tacos.html' , 'w') { |f| f.write(@doc.to_html) }
  end

end

url = 'http://www.tacobell.com/home'
r = Rget.new( url )
r.images