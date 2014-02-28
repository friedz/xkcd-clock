#!/usr/bin/ruby
#encoding: utf-8

require 'RMagick'
require 'optparse'

include Magick

class Time
  def toAngle
    self.utc
    angle = self.hour * 15
    angle += self.min / 4
    self.localtime
    return angle
  end

  def offsetAngle
    self.localtime
    return self.gmt_offset / 240
  end
end

dimension = {width: 1366, height: 768}

time = Time.now
options = {}
options[:innerAngle] = time.toAngle

OptionParser.new do |opts|
  opts.on("-a", "--angle=N", Float, "angle to rotate the map, calculatet from time by default (must be set first)") do |n|
    if options[:local] then
      options[:outerAngle] = n
    else
      options[:innerAngle] = n
    end
  end

  opts.on("-z", "--zone=N", Integer, "specifie timezone to be upside") do |n|
    options[:local] = true
    options[:outerAngle] = options[:innerAngle]
    options[:innerAngle] = n * 15
    options[:outerAngle] += options[:innerAngle]
  end

  opts.on("-l", "--local", "your location up, and turn the outer ring") do
    options[:local] = true
    options[:outerAngle] = options[:innerAngle]
    options[:innerAngle] = time.offsetAngle
    options[:outerAngle] += options[:innerAngle]
  end
end.parse!

inside = ImageList.new("inside.png")
outside = ImageList.new("outside.png")
height = inside.rows
width  = inside.columns


if options[:local] then
  options[:innerAngle] += 180
  options[:outerAngle] += 180
  outside.rotate!(options[:outerAngle])
  outside.crop!(NorthWestGravity, width, height)
end
 
inside.rotate!(options[:innerAngle])
inside.crop!(NorthWestGravity, width, height)

outside.composite!(inside.transparent('white'), 0, 0, OverCompositeOp)
now = Image.new(dimension[:width],dimension[:height])
now.composite!(outside, CenterGravity, OverCompositeOp)
now.write("now.png")
