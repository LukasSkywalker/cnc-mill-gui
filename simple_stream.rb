require_relative 'serial'

filename = ARGV[0]

puts "Running #{filename}"

content = File.read(filename)
code = content.split("\n")

run_program(code)
