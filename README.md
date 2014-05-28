# Gurke

**Gurke** is an experimental, alternative cucumber runner. It ~~steals~~ borrows ideas and concepts from [turnip](https://github.com/jnicklas/turnip), [rspec](http://rspec.info) and tries to avoid [cucumber](https://github.com/cucumber/cucumber/).

That includes * Step definitions in modules * Before, After and Around hooks * Formatters * Partial step inclusion (via modules) * etc. Also new ideas like keyword depended step definitions are planned.

But still **Gurke** is unfinished, not recommended and highly dangerous!

## Installation

Or install it yourself as:

    $ gem install gurke

Or add it to your `Gemfile` and install it using bundler.

## Usage

1. Put features in `features/`.

2. Put support and configuration files as ruby into `features/support/**`.

e.g.

```ruby
# features/support/gurke.rb
require 'gurke/rspec'
require 'tmpdir'

Gurke.configure do |c|
  c.around(:scenario) do |scenario|
    Dir.mktmpdir('gurke') do |dir|
      @__root = Pathname.new(dir)
      scenario.call
    end
  end
end
```

3. Put your step definitions into `features/support/**`.

```ruby
# features/support/steps/file_steps.rb
module FileSteps
  step(/a file "(.*?)" with the following content exists/) do |path, step|
    file = @__root.join(path)

    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, step.doc_string)
  end
end

Gurke.configure{|c| c.include FileSteps }
```

### Keyword specific step definitions

You can also define steps for only a specific keyword. This also allows you to use the same step pattern for different keywords, e.g.

```ruby
module PathSteps
  Given(/^I am on the start page$/) { visit '/' }
  Then(/^I am on the start page$/) { assert current_path == '/' }
end
```

Therefore you can write your scenarios in a documentary style of facts:

```
Scenario: Use the back button
  Given I am on the start page
  When I click on "Go to another page"
  And I click the back button
  Then I am on the start page
```

`And` and `But` steps will inherit the keyword type from the step before, e.g. the `And` step above will be of the `when` type.

### Use the command line runner

Run all scenarios by just calling `bundle exec gurke`. By default scenarios and features tagged with `@wip` will be ignored.

Specify one or more `--tags` or `-t` arguments to filter for specific tags, negate tag filters with `~`.

Examples:

* `--tags a,b` - only run scenarios with tags `@a` AND `@b`
* `-t a -t b` - only run scenarios with tags `@a` OR `@b`
* `-t a,~b` - only run scenarios with `@a` but not `@b`

## TODO

* Lots of things.

## History

Now: * Can finally (start to) test itself.

## Contributing

Send me code.
