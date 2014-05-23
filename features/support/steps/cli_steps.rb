require 'open3'

#
module CLISteps
  step(/I execute "(.*?)"/) do |exec|
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

  step(/the program exit code should be null/) do
    expect(@last_process[0]).to eq 0
  end

  step(/the program exit code should be non-null/) do
    expect(@last_process[0]).to_not eq 0
  end

  step(/the program output should include "(.*?)"/) do |content|
    expect(@last_process[1]).to include content
  end

  step(/the program output should not include "(.*?)"/) do |content|
    expect(@last_process[1]).to_not include content
  end
end

Gurke.configure{|c| c.include CLISteps }
