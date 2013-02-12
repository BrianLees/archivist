require_relative 'archivist'
require_relative 'html_creator'

archivist = Archivist.new
html_writer = HtmlCreator.new
step_defs_json = archivist.generate_archive
html_writer.generate_archive_searcher(step_defs_json)
