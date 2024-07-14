# frozen_string_literal: true

def require_all_from_dir(dir, sort_by_pattern: nil)
  raise ArgumentError, "Directory #{dir} does not exist" unless Dir.exist? dir

  files = Dir["./#{dir}/*.rb"]

  files.sort_by! do |file|
    sort_by_pattern && File.basename(file).match?(sort_by_pattern) ? 0 : 1
  end
  files.each { |file| require file }
end
