require_relative 'lib/api_generator/version'

Gem::Specification.new do |spec|
  spec.name          = 'gemfather'
  spec.version       = ApiGenerator::VERSION
  spec.authors       = ['Domclick Ruby Team']

  spec.summary       = 'Gemfather: API client generator'
  spec.description   = 'Library that helps to generate high-quality API clients'
  spec.homepage      = 'https://github.com/domclick/gemfather'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7'

  spec.metadata = {
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'documentation_uri' => "#{spec.homepage}/blob/main/README.md",
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
  }

  spec.files = Dir[
    'lib/**/*',
    'templates/**/*',
    'gem_template/**/*',
    'gem_template/**/.*.tt',
    'README.md'
  ]
  spec.require_paths = ['lib']
  spec.executables << 'gemfather'

  spec.add_dependency 'activesupport', '>= 6.0'
  spec.add_dependency 'dry-configurable', '~> 0.11'
  spec.add_dependency 'faraday', '>= 0.17', '< 2'
  spec.add_dependency 'faraday_middleware', '>= 0.13', '< 2'
  spec.add_dependency 'hashie', '>= 3.0', '< 5'
  spec.add_dependency 'thor', '>= 0.14', '< 2.0'
  spec.add_dependency 'zeitwerk', '~> 2.2'
end
