require "./lib/rescata"

Gem::Specification.new do |s|
  s.name              = "rescata"
  s.version           = Rescata::VERSION
  s.summary           = "Microlibrary for rescue exceptions declaratively in your Ruby classes."
  s.description       = "Microlibrary for rescue exceptions declaratively in your Ruby classes."
  s.authors           = ["Julio Lopez"]
  s.email             = ["ljuliom@gmail.com"]
  s.homepage          = "http://github.com/TheBlasfem/rescata"
  s.files = Dir[
    "LICENSE",
    "README.md",
    "lib/**/*.rb",
    "*.gemspec",
    "test/**/*.rb"
  ]
  s.license           = "MIT"
  s.add_development_dependency "cutest", "1.1.3"
end