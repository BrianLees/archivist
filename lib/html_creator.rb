require 'json'

class HtmlCreator

  def generate_archive_searcher(step_defs_data)
    step_defs = parse_data(step_defs_data)
    write_html(step_defs)
  end

  def parse_data(data)
    JSON.parse(data)
  end

  def write_html(step_defs)
    html_file = File.new("output.html", "w")
    html_file << constructed_header(step_defs)
    step_defs.each do |step|
      html_file << "<tr>"
      html_file << "<td>#{step['type']}</td>"
      html_file << "<td>#{step['matcher']}</td>"
      html_file << "<td>[#{step['table']}]</td>"
      html_file << "<td><a href=\"#{step['location']}\">#{step['location']}</a></td>"
      html_file << "</tr>"
    end
    html_file << "</table>"
  end

  def constructed_header(step_defs)
    '<table><th>Type</th><th>Matcher</th><th>Table</th><th>Source file</th>'
  end
end
