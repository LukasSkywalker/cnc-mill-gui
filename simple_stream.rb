#!/usr/bin/env ruby
require_relative 'serial'

stdin = ARGF.read
filename = ARGV[0]

if filename
  content = File.read(filename)
end

input = stdin || content

code = input.split("\n")

run_program(code)
