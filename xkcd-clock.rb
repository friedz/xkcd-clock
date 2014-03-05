#!/usr/bin/ruby
#encoding: utf-8

require 'RMagick'
require 'optparse'

include Magick

class Time
  def toAngle
    angle = self.utc.hour * 15
    angle += self.utc.min / 4
    return angle
  end

  def offsetAngle
    return self.localtime.gmt_offset / 240
  end
end

dimension = {width: 1366, height: 768}
output = "/home/friedrich/.i3/"
pictures = "/home/friedrich/dokumente/projekte/xkcd-clock"

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
  
  opts.on("-m", "--midnight", "rotates everything that the location on the upper side has midnight") do
    options[:local] = true
    options[:outerAngle] = 0
  end

  opts.on("-z", "--zone=N", Integer, "specifie timezone to be upside") do |n|
    options[:local] = true
    options[:outerAngle] = - options[:innerAngle]
    options[:innerAngle] = -(n * 15)
    options[:outerAngle] += options[:innerAngle]
  end

  opts.on("-l", "--local", "your location up, and turn the outer ring") do
    options[:local] = true
    options[:outerAngle] = - options[:innerAngle]
    options[:innerAngle] = - time.offsetAngle
    options[:outerAngle] += options[:innerAngle]
  end

  opts.on("-o", "--outputpath=STRING", String, "sets the path wehre the outputfile will be found afterwards") do |path|
    output = path
  end

  opts.on("--artist", "tells you that the picture was made by Randall Munroe (xkcd.com/now)") do
    puts "picture by Randall Munroe"
    puts "  http://xkcd.com/now"
  end
end.parse!

Dir.chdir(pictures)

inside  = ImageList.new("inside.png")
outside = ImageList.new("outside.png")
height  = inside.rows
width   = inside.columns


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

Dir.chdir(output)
now.write("now.png")
