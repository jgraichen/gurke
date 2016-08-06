require 'open3'

#
module CLISteps
  def _execute(args = nil)
    Dir.chdir(@__root) do
      Bundler.with_clean_env do
        cmd = ['ruby']
        cmd << '-I' << Gurke.root.join('..', 'lib').realpath
        cmd << '-S' << Gurke.root.join('..', 'bin', 'gurke').realpath
        cmd << args.to_s

        out, err, status = Open3.capture3 cmd.join ' '

        @last_process = [Integer(status), out, err]
      end
    end
  end

  step(/I run the tests with "(.*?)"/, :_execute)

  step('I run the tests', :_execute)

  step(/the program exit code should be null/) do
    expect(@last_process[0]).to eq 0
  end

  step(/the program exit code should be non-null/) do
    expect(@last_process[0]).to_not eq 0
  end

  def _cli_include_content(content)
    expect(@last_process[1] + @last_process[2]).to include content
  end

  step(/the program output should include "(.*?)"/, :_cli_include_content)

  def _cli_not_include_content(content)
    expect(@last_process[1] + @last_process[2]).to_not include content
  end

  step(/the program output should not include "(.*?)"/,
       :_cli_not_include_content)

  step(/all scenarios have passed/) do
    _cli_include_content 'scenarios: 0 failing, 0 pending'
  end
end

Gurke.config.include CLISteps
