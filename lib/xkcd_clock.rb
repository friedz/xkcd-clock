#!/usr/bin/ruby
#encoding: utf-8

require 'RMagick'

include Magick

class Time
  def toAngle
    utc = self.utc
    angle = utc.hour * 15
    angle += utc.min / 4
    return angle
  end

  def offsetAngle
    zone = self
    return zone.gmt_offset / 240
  end
end

class XKCD_Clock
  @@pic = {inside: "../inside.png", outside: "../outside.png"}
  @angle = {}
  @dimensions = {}

  def initialize *timeGeo
    @time, width, height = *timeGeo
    if @time.is_a? Numeric then
      width, height, @time = @time, width, height
    end
    if @time.nil? then
      @time = Time.now
    end
    if !!width && !!height then
      self.set_geometry(width, height)
    end
  end

  def update *t
    @time = t[0]
    puts @time.class
    if @time.nil? then
      @time = Time.new
    elsif !(@time.is_a? Time) then
      raise TypeError, 'argument musst be of class or Time (or nil)'
    end
    
    if !!@mode then
      self.set_mode @mode
    end
  end

  def set_geometry *dim
    @dimension = {}
    @dimension[:width], @dimension[:height] = *dim
  end 

  def geometry?
    return @dimension
  end

  def angle?
    return @angle
  end

  def set_angle inner, outer
    @angle[:inner] = inner
    @angle[:outer] = outer
    @mode = :manual
  end

  def set_mode mod
    @angle = {}
    case mod
    when :manual
      @angle[:inner] = @time.toAngle
      @angle[:outer] = 0
      @mode = :classic
    when :classic
      @angle[:inner] = @time.toAngle
      @angle[:outer] = 0
    when :midnight
      @angle[:inner] = @time.toAngle + 180
      @angle[:outer] = 180
    when :local
      offset = -@time.offsetAngle
      @angle[:inner] = offset
      @angle[:outer] = offset - @time.toAngle
    else
      raise TypeError, 'argument musst be one of :classic, :midnight or :local'
    end
  end
  
  def classic
    self.set_mode :classic
  end

  def midnight
    self.set_mode :midnight
  end

  def local
    self.set_mode :local
  end

  def mode?
    return @mode
  end

  def compose
    inside  = ImageList.new(@@pic[:inside])
    outside = ImageList.new(@@pic[:outside])
    height  = inside.rows
    width   = inside.columns

    outside.rotate!(@angle[:outer])
    outside.crop!(NorthWestGravity, width, height)

    inside.rotate!(@angle[:inner])
    inside.crop!(NorthWestGravity, width, height)
    
    if @dimension.empty? then
      @dimension[:width], @dimension[:height] = width, height
    end

    outside.composite!(inside.transparent('white'), 0, 0, OverCompositeOp)
    now = Image.new(@dimension[:width], @dimension[:height])
    now.composite!(outside, CenterGravity, OverCompositeOp)

    return now
  end

  def recompose *time
    self.update *time
    self.compose
  end
end
