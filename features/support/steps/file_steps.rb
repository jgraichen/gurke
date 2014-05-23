#
module FileSteps
  def write_file(path, content)
    file = @__root.join(path)

    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, content)
  end

  step(/I am in a project using gurke/) do
    write_file 'Gemfile', <<-EOS
      source 'https://rubygems.org'
      gem 'gurke', path: '#{File.dirname(Gurke.root)}'
    EOS
  end

  step(/a file "(.*?)" with the following content exists/) do |path, step|
    write_file(path, step.doc_string)
  end
end

Gurke.config.include FileSteps
