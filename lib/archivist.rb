class Archivist
  def initialize(step_dir="./step_definitions")
    @step_definition_dir = step_dir
    @step_defs = Array.new
  end

  def generate_archive
    list_of_step_defs = get_step_def_list
    generate_archive_searcher
  end

  def get_step_def_list
    Dir.glob(File.join(@step_definition_dir,'**/*.rb')).each do |step_file|
      File.new(step_file).read.each_line do |line|
        next unless line =~ /^\s*(?:Given|When|Then)\s+\//
        step_def = /(Given|When|Then)\s*\/\^(.*)\$\/\s*do\s*(?:$|\|(.*)\|)/.match(line).captures
        # step_def = /(?:Given|When|Then)\s*\/(.*)\/([imxo]*)\s*do\s*(?:$|\|(.*)\|)/.match(line).captures
        step_def << step_file
        step_def_hash = insert_parameters(step_def)
        @step_defs << step_def_hash
      end
    end
  end

  def insert_parameters(step)
    step_hash = Hash.new
    step_hash[:type] = step[0]
    step_hash[:location] = step[3]
    unless step[2].nil?
      params = step[2].split(' ').reverse
      replaced_pieces = Array.new
      step[1].split(' ').each do |piece|
        if piece =~ /(\(.*\))/
          piece = piece.gsub(/(\(.*\))/, params.pop)
        end
        replaced_pieces << piece
      end
      step_hash[:matcher] = replaced_pieces.join(' ')
    else
      step_hash[:matcher] = step[1]
    end
    step_hash
  end

  def generate_archive_searcher
    file = File.new("output.html", "w")
    file << "<table><th>Type</th><th>Matcher</th><th>Source file</th>"
    @step_defs.each do |step|
      file << "<tr>"
      file << "<td>#{step[:type]}</td>"
      file << "<td>#{step[:matcher]}</td>"
      file << "<td><a href=\"#{step[:location]}\">#{step[:location]}</a></td>"
      file << "</tr>"
    end
      file << "</table>"
  end
end
