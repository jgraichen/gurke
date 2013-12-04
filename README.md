# Gurke

**Gurke** is a highly opinionated cucumber toolkit overtaking cucumbers formatter to add webm flv video recording with headless (xvfb), multiple output formatters, global available current step and scenario and additional hooks.

Unfinished, not recommended, highly dangerous!

## Installation

Add this line to your application's Gemfile:

    gem 'gurke'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gurke

## Usage

```
require 'gurke'

require 'cucumber/formatter/pretty'
require 'cucumber/formatter/junit'
require 'gurke/formatters/headless'

class MyExternalTool < ::Gurke::Formatters::Base
  def quiet?
    options[:quiet]
  end

  def before_features(features)
    puts 'BUUUH!' unless quiet?
  end
end

Gurke::Formatter.config do
  use Cucumber::Formatter::Pretty
  use Cucumber::Formatter::JUnit
  use MyExternalTool, quiet: true
  use Gurke::Formatters::Headless, dir: 'report/html', recording: true, record_all: true
end
```

```
Gurke.current.step
Gurke.current.scenario

Gurke.before :features do |*args|
  # ...
end

Gurke.before :feature_element do |*args|
  # ...
end

Gurke.after :step_result do |*args|
  # ...
end

#...

```

## TODO

* Headless Dir & HTML Template

## Contributing

Don't even think about it.
