require 'open-uri'
require 'nokogiri'
require 'rss'
require 'aws-sdk'

VERSION = '0.0.1'
USER_AGENT = "Wit Feeder v#{VERSION} - https://github.com/kyanny/wit-feeder"
HOST= 'wit.flakiness.es'

def link(path)
  "http://#{HOST}#{path}"
end

def _open(url)
  open(url, { 'User-Agent' => USER_AGENT })
end

rss = RSS::Maker.make('atom') do |maker|
  maker.channel.author = 'omo'
  maker.channel.updated = Time.now
  maker.channel.about = 'https://github.com/kyanny/wit-feeder'
  maker.channel.title = 'WiT: Writing is Thinking (unofficial feed)'


  html = _open(link '/').read
  doc = Nokogiri::HTML(html)
  doc.css('.month-list a').each do |month|
    next if month['href'] == '/pages' # skip pages
    html = _open(link month['href']).read
    doc = Nokogiri::HTML(html)
    doc.css('.note-item a').each do |note|
      permalink = note['href']
      permalink.match(%r!/(\d+)/(\d+)/(\d+)/(\d{2})(\d{2})(?:-.*)?\z!)
      year, month, day, hour, minute = $1, $2, $3, $4, $5
      html = _open(link permalink).read
      body = Nokogiri::HTML(html).css('.note.content').text.strip

      maker.items.new_item do |item|
        item.link = link(permalink)
        item.title = note.text
        item.summary = body
        item.updated = Time.local(year, month, day, hour, minute)
      end
    end
  end
end

AWS.config({
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  })

s3 = AWS::S3.new
bucket = s3.buckets['kyanny']
object = bucket.objects.create('wit.rss', rss.to_s)
object.acl = :public_read
