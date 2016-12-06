#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Reality #nodoc
  module Facets #nodoc

    class Facet < Reality::BaseElement
      attr_reader :facet_container
      attr_reader :key
      attr_accessor :required_facets
      attr_accessor :suggested_facets

      def initialize(facet_container, key, options = {}, &block)
        options = options.dup
        @key = key
        @facet_container = facet_container
        @required_facets = []
        @suggested_facets = []
        facet_container.send :register_facet, self
        super(options, &block)
        facet_container.target_manager.targets.each do |target|
          target.extension_module.class_eval <<-RUBY
            def #{self.key}?
              !!(@#{self.key}_facet_enabled ||= false)
            end

            private

            def _enable_facet_#{self.key}!
              @#{self.key}_facet_enabled = true
              (@enabled_facets ||= []) << :#{self.key}
            end

            def _disable_facet_#{self.key}!
              @#{self.key}_facet_enabled = false
              @facet_#{self.key} = nil
              (@enabled_facets ||= []).delete(:#{self.key})
            end
          RUBY
        end
      end

      def enhance(model_class, &block)
        target_manager = facet_container.target_manager
        target = target_manager.target_by_model_class(model_class)

        extension_name = "#{::Reality::Naming.pascal_case(self.key)}#{model_class.name.gsub(/^.*\:\:([^\:]+)/, '\1')}Facet"
        definitions = target_manager.container.facet_definitions
          definitions.class_eval "class #{extension_name} < Reality.base_element(:container_key => :#{target.key}); end"
        extension_instance = definitions.const_get(extension_name)
        extension_instance.class_eval(&block) if block_given?

        model_extension = target.extension_module
        model_extension.class_eval <<-RUBY
          def #{self.key}
            self.facet_#{self.key}
          end

          def facet_#{self.key}
            raise "Attempted to access '#{self.key}' facet for model '#{model_class.name}' when facet disabled." unless #{self.key}?
            @facet_#{self.key} ||= #{extension_instance.name}.new(self)
          end
        RUBY
      end
    end
  end
end

