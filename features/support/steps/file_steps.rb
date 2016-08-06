#
module FileSteps
  def _write_file(path, content)
    file = @__root.join(path)

    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, content)
  end

  def _read_file(path)
    file = @__root.join(path)

    File.read(file)
  end

  step(/a file "(.*?)" with the following content exists/) do |path, step|
    _write_file(path, step.doc_string)
  end

  # Then(/a file "(.*?)" with the following content exists/) do |path, step|
  #   expect(_read_file(path)).to eq step.doc_string
  # end
end

Gurke.config.include FileSteps
