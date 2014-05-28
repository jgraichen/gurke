require 'open3'

#
module CLISteps
  def _execute(exec)
    Dir.chdir(@__root) do
      Bundler.with_clean_env do
        Open3.popen2e(exec) do |_, stdout_err, wait_thr|
          exit_status = wait_thr.value
          stdout_err  = stdout_err.read

          @last_process = [exit_status.to_i, stdout_err]
        end
      end
    end
  end

  step(/I execute "(.*?)"/, :_execute)

  step('I execute all scenarios') do
    _execute 'bundle exec gurke'
  end

  step(/the program exit code should be null/) do
    expect(@last_process[0]).to eq 0
  end

  step(/the program exit code should be non-null/) do
    expect(@last_process[0]).to_not eq 0
  end

  def _cli_include_content(content)
    expect(@last_process[1]).to include content
  end

  step(/the program output should include "(.*?)"/, :_cli_include_content)

  def _cli_not_include_content(content)
    expect(@last_process[1]).to_not include content
  end

  step(/the program output should not include "(.*?)"/,
       :_cli_not_include_content)

  step(/all scenarios have passed/) do
    _cli_include_content 'scenarios: 0 failing, 0 pending'
  end
end

Gurke.configure {|c| c.include CLISteps }
