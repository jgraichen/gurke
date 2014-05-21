# Gurke

**Gurke** is an experimental, alternative cucumber runner. It ~~steals~~ borrows ideas and concepts from [turnip](https://github.com/jnicklas/turnip), [rspec](http://rspec.info) and tries to avoid [cucumber](https://github.com/cucumber/cucumber/).

That includes * Step definitions in modules * Before, After and Around hooks * Formatters * Partial step inclusion (via modules) * etc. Also new ideas like keyword depended step definitions are planned.

But still **Gurke** is unfinished, not recommended and highly dangerous!

## Installation

Or install it yourself as:

    $ gem install gurke

Or add it to your `Gemfile` and install it using bundler.

## Usage

### 1. Put features in `features/`.

### 2. Put support and configuration files as ruby into `features/support/**`.

e.g.

```
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

### 3. Put your step definitions into `features/support/**`.

```
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

## TODO

* Lot of things.

## History

Now: * Can finally (start to) test itself.

## Contributing

Send me code.
