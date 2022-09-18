require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext/module/introspection'
require 'active_support/core_ext/object/try'
require 'dry-configurable'
require 'faraday_middleware'
require 'faraday'
require 'hashie'
require 'delegate'
require 'thor'
require 'erb'

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

module ApiGenerator
end
