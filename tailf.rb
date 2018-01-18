#!/usr/bin/env ruby

require 'file/tail'
require 'json'

class String
  TO_LENGTH = 30

  def to_l(to_length = nil)
    to_length(self, to_length || TO_LENGTH)
  end

  def to_length(string, to_length)
    diff = to_length - length
    return "#{self}#{diff.times.map{ ' ' }.join}" if diff > 0
    self
  end
end

filename = ARGV.pop or fail "Usage: #$0 number filename"
number = (ARGV.pop || 0).to_i.abs

File::Tail::Logfile.open(filename) do |log|
  log.interval = 0.1
  log.max_interval = 0.1
  log.backward(number)
  log.tail do |line|
    json = JSON.parse(line)
    worker = "[#{(json['worker'] || 'no_worker')}]"
    status = "[#{(json['status'] || 'info' )}]"
    puts "#{worker.to_l} #{status.to_l(9)}: #{json['message']}"
  end
end
