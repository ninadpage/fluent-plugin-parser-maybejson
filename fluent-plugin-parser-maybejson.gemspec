
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-parser-maybejson"
  spec.version       = "0.1.2"
  spec.authors       = ["Ninad Page"]
  spec.email         = ["ninadpage@users.noreply.github.com"]

  spec.summary       = %q{A fluent parser plugin to safely parse JSON formatted logs while retaining non-JSON logs.}
  spec.description   = %q{See README at https://github.com/ninadpage/fluent-plugin-parser-maybejson/.}
  spec.homepage      = "https://github.com/ninadpage/fluent-plugin-parser-maybejson/"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "fluentd", "~> 1.4.0"
end
