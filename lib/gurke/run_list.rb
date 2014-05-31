module Gurke
  #
  # A {RunList} is a list of {Background}, {Scenario}
  # or {Step} objects that can be {#run}.
  #
  class RunList < Array
    #
    # Run all backgrounds from this list.
    #
    # @api private
    #
    def run(runner, reporter, *args)
      each do |o|
        o.run runner, reporter, *args
      end
    end
  end
end
