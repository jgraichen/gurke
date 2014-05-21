require 'childprocess'

#
module CLISteps
  step(/I execute "(.*?)"/) do |exec|
    @last_process = ::ChildProcess.build('bash', '-lc', exec)
    @last_process.cwd = @__root
    @last_process.start

    begin
      @last_process.poll_for_exit(30)
    rescue ::ChildProcess::TimeoutError => e
      @last_process.stop
      raise e
    end
  end

  step(/the program exit code should be "(.*?)"/) do |exitcode|
    expect(@last_process.exit_code).to eq Integer(exitcode)
  end
end

Gurke.configure{|c| c.include CLISteps }
