#!/usr/bin/env ruby

require 'json'

class LedStatus

  def self.run!
    led_status = LedStatus.new
    $stdout.sync = true

    IO.popen(I3STATUS_CMD, 'r') do |pipe|
      # Skip the first line which contains the version header and
      # the second line containing the start of the infinite array
      2.times { $stdout.puts pipe.readline }
      # Do your job
      pipe.each { |line| $stdout.puts led_status.prepend_to line }
    end
  end

  I3STATUS_CMD = 'i3status'

  LED_STATUS_CMD = 'xset q | grep "LED mask"'

  LED_MASK_RE = /LED mask:\s+(\d+)$/

  LED_MASKS = [
    ['altgr',  0b1111101000, '#B58900'],
    ['scroll', 0b0000000100, '#2AA198'],
    ['num',    0b0000000010, '#859900'],
    ['caps',   0b0000000001, '#DC322F'],
  ]

  def current_mask
    matches = LED_MASK_RE.match(`#{LED_STATUS_CMD}`)
    matches && matches[1].to_i || 0
  end

  def led_status
    LED_MASKS.select do |_, mask, _|
      mask & current_mask == 1
    end.map do |name, _, color|
      { full_text: name.upcase, name: name, color: color }
    end
  end

  def prepend_to(line)
    line, sep = line[1..-1], line[0] if line[0] == ','

    json = JSON.parse line.chomp
    led_status.each { |led| json.unshift led }

    output = json.to_json
    output.prepend sep unless sep.nil?

    output
  end
end

LedStatus.run! if $0 == __FILE__
