# encoding: UTF-8
require 'open-uri'
require File.expand_path('alfredXML')

query = ARGV[0] ? ARGV[0].strip.downcase : ""

# Fetch the HTML and parse it only when the query is empty
# and save the results for further filtering

if query.empty?
  html = open('http://patria.md/movies/')
  doc = html.read

  # Parse HTML with regular expressions. Brace yourself!
  # OH-GOD-WHY
  titles = doc.scan(/<div class=\"title\">.+<\/a><\/div>/).map{|i| i.split(/a href=/).last.split('">').last[0..-11] }
  images = doc.scan(/<div class=\"image\">.+<\/a><\/div>/).map{|i| i.scan(/src=\".+\" class/).first.split(' ').first[5..-2] }
  sessions_raw = doc.scan(/(\d{2}:\d{2}| \/ \d{2}:\d{2})/)
  sessions = sessions_raw.flatten.map{|i| i.size < 6 ? "|#{i}" : i }.join('').split("|").select{|i| !i.empty? }
  links = doc.scan(/<div class="title"><a href="[^"]+/).map{|i| i[28..-1]}
  youtubes = links.map do |link|
    doc = open(link).read
    youtube = doc.scan(/<iframe width="\d+" height="\d+" src="[^"]+/).first.split('src="').last
    "http:#{youtube}"
  end
  # OH-GOD-WHY indeed...

  # Save results on disk
  # Entries are grouped by category, each on separate line
  File.open('/tmp/patria.txt', 'w') do |f|
    [titles, images, sessions, youtubes].each do |group|
      f.puts group.join("\n")
      # Group separator
      f.puts('-' * 10)
    end
  end
else
  # Load information from disk
  # 1 line of code.. I <3 Ruby
  titles, images, sessions, youtubes = File.read('/tmp/patria.txt').split(/\n\-+\n/).map{|group| group.split("\n") }
end

output = titles.count.times.map do |i|
  title = titles[i]
  image = images[i]
  session = sessions[i]
  youtube = youtubes[i]

  # Filtering results
  next unless title.downcase.include?(query) || session.include?(query)

  # Saving the image
  image_name = image.split('/').last
  image_dir = '/tmp/'
  image_path = image_dir + image_name
  unless File.exists? image_path
    File.open(image_path,'wb'){|f| f.write open(image).read }
  end

  {
    :uid          => title,
    :arg          => youtube,
    :icon         => image_path,
    :valid        => "yes",
    :title        => title,
    :subtitle     => session,
    :autocomplete => title
  }
end

puts alfredXML(output)