# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll/archimate/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-archimate"
  spec.version       = Jekyll::Archimate::VERSION
  spec.authors       = ["Mark Morga"]
  spec.email         = ["markmorga@gmail.com"]

  spec.summary       = %q{Jekyll plugins to support documenting ArchiMate models.}
  spec.description   = %q{Produces SVG diagrams and a JSON index useful for
                          search from an ArchiMate model file.}
  spec.homepage      = "https://github.com/mmorga/jekyll-archimate"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", "~> 3.0"
  spec.add_runtime_dependency "archimate", ">= 1.1"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
