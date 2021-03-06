require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Aggregate constraint
          #
          # It is used to perform checks against a list of constraints-functors
          # or lambdas.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param1,
          #        :constraint => all_of(
          #          not_nil,
          #          satisfies("Should be moderate") { |v| v < 100 }
          #        )
          #    end
          #
          #    i = Piece.new(:param1 => nil)
          #    i.param1 # raise ParameterValueInvalid
          #    i = Piece.new(:param1 => 200)
          #    i.param1 # raise ParameterValueInvalid with description
          #    i = Piece.new(:param1 => 50)
          #    i.param1 # => 50
          class AllOf < self
            attr_reader :constraints

            def initialize(constraints)
              @constraints = constraints
              self.if(Parametrized.any)
            end

            protected

            def check(parameter, value, instance)
              constraints.each do |c|
                instance.instance_exec(parameter, value, &c)
              end
            end
          end
        end
      end
    end
  end
end
