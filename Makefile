default: lint test

setup:
	bundle install

test:
	bin/rspec

lint:
	bin/rubocop

cleanup:
	rm -f gemfather-*.gem

build:
	gem build gemfather.gemspec

publish:
	gem push gemfather-*.gem

deploy: build publish cleanup