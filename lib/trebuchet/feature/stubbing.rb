class Trebuchet
  class Feature
    module Stubbing

      def stub(state)
        self.class.stubbed_features[name] = state
      end

      def stubbed?
        !!self.class.stubbed_features[name]
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def dismantle_stubs
          @stubbed_features = nil
        end

        def stubbed_features
          @stubbed_features ||= {}
        end

      end

    end
  end
end