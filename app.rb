require 'httparty'
require 'open-uri'
require 'nokogiri'
require 'pry'

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
    styles = ''
    @doc.css('[rel="stylesheet"]').map do |l| 
      l.remove
      if l['href'].index('http') == 0
	styles += open( URI.encode(l['href'])).read
      else
	styles += open( @base_url + l['href']).read
      end
    end
    style = Nokogiri::XML::Node.new "style", @doc 
    style['type'] = 'text/css'
    style.content = styles
    @doc.at_css('head') << style
  end

  def images
    @doc.css('img').map do |img| 
      if img['src'].index('http') == 0
        src = img['src']
      elsif img['src'].index('/') == 0
	src = @base_url + img['src']
      else
	src = @base_url + '/' + img['src']
      end
      binding.pry
      image = open( src )
      content_type = image.content_type
      img.attributes['src'].value = 'data:'+ content_type +';base64,' + Base64.encode64(image.read)
    end
  end

  def save
      self.csss
      self.images
    File.open( 'tmp.html' , 'w') { |f| f.write(@doc.to_html) }
  end

end

url = 'http://helenvholmes.com/2014/03/29/well-made-co.html'
r = Rget.new( url )
r.save