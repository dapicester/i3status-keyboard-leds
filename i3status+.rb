#!/usr/bin/env ruby

require 'json'

class LedStatus
  LED_STATUS_CMD = 'xset q | grep "LED mask"'.freeze

  LED_MASK_RE = /LED mask:\s+(\d+)$/.freeze

  LED_MASKS = [
    ['altgr',  0b1111101000, '#B58900'],
    ['scroll', 0b0000000100, '#2AA198'],
    ['num',    0b0000000010, '#859900'],
    ['caps',   0b0000000001, '#DC322F']
  ].freeze

  def current_mask
    matches = LED_MASK_RE.match(`#{LED_STATUS_CMD}`)
    matches && matches[1].to_i || 0
  end

  def leds
    LED_MASKS.select { |_, mask, _| mask & current_mask == 1 }.map do |name, _, color|
      { full_text: name.upcase, name: name, color: color }
    end
  end
end

class I3StatusPlus
  I3STATUS_CMD = 'i3status'

  def self.run!
    # Unbuffered output
    $stdout.sync = true

    status_plus = new

    IO.popen(I3STATUS_CMD, 'r') do |pipe|
      # Skip the first line which contains the version header and
      # the second line containing the start of the infinite array
      2.times { $stdout.puts pipe.readline }
      # Do your job
      pipe.each { |line| $stdout.puts status_plus.add_leds_to line }
    end
  end

  attr_reader :led_status

  def initialize
    @led_status = LedStatus.new
  end

  def add_leds_to(line)
    line, sep = line[1..-1], line[0] if line[0] == ','

    json = JSON.parse line.chomp
    led_status.leds.each { |led| json.unshift led }

    output = json.to_json
    output.prepend sep unless sep.nil?

    output
  end
end

I3StatusPlus.run! if $PROGRAM_NAME == __FILE__
