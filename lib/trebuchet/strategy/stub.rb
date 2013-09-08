class Trebuchet
  module Strategy

    class Stub < Trebuchet::Strategy::Base
      attr_reader :state

      def initialize(state)
        @state = state
      end

      def launch_at?(user, request = nil)
        state == :launched
      end

      def needs_user?
        false
      end

      def to_s
        "stub (#{state}}"
      end

      def export
        super state
      end

    end

  end
end