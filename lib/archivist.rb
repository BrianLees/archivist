require 'json'

class Archivist
  TYPE, MATCHER, PARAMS, FILE = 0,1,2,3

  def initialize(step_dir="./step_definitions")
    @step_definition_dir = step_dir
    @step_defs = Array.new
  end

  def generate_archive
    get_step_def_list
    prepare_for_output
  end

  def get_step_def_list
    Dir.glob(File.join(@step_definition_dir,'**/*.rb')).each do |step_file|
      File.new(step_file).read.each_line do |line|
        next unless line =~ /^\s*(?:Given|When|Then)\s+\//
        step_def = /(Given|When|Then)\s*\/\^(.*)\$\/\s*do\s*(?:$|\|(.*)\|)/.match(line).captures
        step_def << step_file
        step_def_hash = parse_step(step_def)
        @step_defs << step_def_hash
      end
    end
  end

  def parse_step(step)
    step_hash = Hash.new
    step_hash[:type] = step[TYPE]
    step_hash[:location] = step[FILE]
    unless step[PARAMS].nil?
      variable_count = step[MATCHER].scan(/(\(.*?\))/).count
      step[PARAMS] = step[PARAMS].split(' ')
      param_count = step[PARAMS].count
      step[MATCHER] = swap_in_params(step[MATCHER],step[PARAMS])
      step_hash[:table] = step[PARAMS].last if param_count - variable_count > 0
    end
    step_hash[:matcher] = step[MATCHER]
    step_hash
  end

  def swap_in_params(matcher, params)
    params = params.reverse
    replaced_pieces = Array.new
    matcher.split(' ').each do |piece|
      piece = piece.gsub(/(\(.*?\))/, params.pop.gsub(',','')) if piece =~ /(\(.*?\))/
      replaced_pieces << piece
    end
    replaced_pieces.join(' ')
  end

  def prepare_for_output
    @step_defs.to_json
  end

end
