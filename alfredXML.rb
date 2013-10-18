def alfredXML(items=[])
  xml_output =  "<?xml version=\"1.0\"?>\n"
  xml_output << "<items>\n"

  items.compact.each do |item|
    xml_output << "\t<item uid=\"#{item[:uid]}\" arg=\"#{item[:arg]}\" valid=\"#{item[:valid] || "yes"}\" autocomplete=\"#{item[:autocomplete]}\">\n"
    xml_output << "\t\t<title>#{item[:title]}</title>\n"
    xml_output << "\t\t<subtitle>#{item[:subtitle]}</subtitle>\n"
    xml_output << "\t\t<icon>#{item[:icon]}</icon>\n"
    xml_output << "\t</item>\n"
  end

  xml_output << "</items>"
  xml_output
end
