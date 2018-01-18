#!/usr/bin/env ruby

require 'file/tail'
require 'json'
require 'terminfo'

LEFT_WIDTH = 42
LINE_WIDTH = TermInfo.screen_size.last - LEFT_WIDTH

class String
  TO_LENGTH = 30

  def to_l(to_length = nil)
    diff = (to_length || TO_LENGTH) - length
    return "#{self}#{diff.times.map{' '}.join}" if diff > 0
    self
  end

  def indented
    parts = self.scan(/.{1,#{LINE_WIDTH}}/)
    res = parts.shift
    left_margin = LEFT_WIDTH.times.map{' '}.join
    parts.each do |part|
      res = "#{res}\n#{left_margin}#{part}"
    end
    res
  end
end

def display(json)
  worker = "[#{(json['worker'] || 'no_worker')}]"
  status = "[#{(json['status'] || 'info' )}]"
  puts "\e[34m#{worker.to_l}\e[0m \e[94m#{status.to_l(9)}:\e[0m #{(json['message'] || '').indented}"
end

filename = ARGV.pop or fail "Usage: #$0 number filename"
number = (ARGV.pop || 0).to_i.abs

File::Tail::Logfile.open(filename) do |log|
  log.interval = 0.1
  log.max_interval = 0.1
  log.backward(number)
  log.tail do |line|
    display(JSON.parse(line))
  end
end
