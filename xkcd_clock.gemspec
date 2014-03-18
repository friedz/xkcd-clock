#encoding: utf-8

Gem::Specification.new do |spec|
  spec.name                   = 'xkcd_clock'
  spec.date                   = Time.now.strftime "%d.%m.%Y"
  spec.authors                = ["Friedrich Schwedler"]
  spec.email                  = 'friedrich@mathphys.fsk.uni-heidelberg.de'
  spec.files                  = ["lib/xkcd_clock.rb"]
  spec.homepage               = 'https://github.com/friedz/xkcd_clock'
  spec.add_runtime_dependency   "RMagick"
end
