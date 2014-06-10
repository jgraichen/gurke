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

You can also use an existing method as a step:

```ruby
module MySteps
  def do_something(arg)
    # ...
  end

  step(/I do something: "(.*?)"/, :do_something)

  # Easy call it from another step
  step(/I do something else/) { do_something('abc') }
end
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

### Included Step Definitions & Hooks

Each scenario runs in it's own world. All modules registered to be included will be included in this world. Before and after scenario or step hooks will also be executed within this world. All steps are run in this world.

You can define hooks similar to RSpec:

```ruby
Gurke.configure do |config|
  config.before(:scenario) do
    visit '/' # Example: Start each scenario on index page
  end

  config.after(:features) do
    # Do some cleanup code etc.
  end
end
```

The following hooks are available:

* `:features`: Will be run before and after every feature. Use to to initially setup or teardown needed resources e.g. setup capybara.
* `:feature`: Will be run before and after any feature.
* `:scenario`: Same for any scenario.
* `:step`: Can be used to e.g. screenshot browser for every step.

### Use the command line runner

Run all scenarios by just calling `bundle exec gurke`. By default scenarios and features tagged with `@wip` will be ignored.

Specify one or more `--tags` or `-t` arguments to filter for specific tags, negate tag filters with `~`.

Examples:

* `--tags a,b` - only run scenarios with tags `@a` AND `@b`
* `-t a -t b` - only run scenarios with tags `@a` OR `@b`
* `-t a,~b` - only run scenarios with `@a` but not `@b`

You can also specify a list of files that will be run:

```
gurke features/my_feature.feature
```

If you append one or more line numbers - separated by dashes - only the scenarios defined around the given lines will be run:

```
gurke features/my_feature.feature:14:34
```

### DRb background server (experimental)

You can run a DRb server in the background that has a running test environment (whatever that means to you) by running `gurke --drb-server`. This will load your test environment and execute all before `:system` hooks.

You can later run your features (or specific features) by running `gurke --drb`. That will run the features in the already loaded DRb server, including all other hooks.

Remember to reload e.g. your step definitions before `:features` to pick up changes:

```ruby
  config.before(:features) do
    Dir['features/steps/**/*.rb'].each{|f| load f }
  end
```

Use the after `:system` hook to shutdown resources.

## TODO

* Import (step definition) modules based on tags (rspec: `config.include MyCLISteps, cli: true`)
* Add `context`/`ctx` object to world providing current feature/scenario/step
* Allow to define scenario/feature specific after hook in steps e.g. to close opened resources
* Random run order (rspec)
* Using strings with placeholders as step pattern (turnip)
* Custom placeholders (turnip)
* Define scenario specific after hook in a step (e.g. to close opened resource)
* More reporters (NyanCat / JUnit / TeamCity / Adapter to run multiple reporters)
* SimpleCov support (and use it in own tests)

## History

Now: * Can finally (start to) test itself.

## Contributing

Send me code.
