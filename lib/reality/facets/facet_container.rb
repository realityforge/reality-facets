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
    module FacetContainer
      def facet?(key)
        facet_by_name?(key)
      end

      def facet_by_name?(key)
        !!facet_map[key.to_s]
      end

      def facet_by_name(key)
        facet = facet_map[key.to_s]
        Facets.error("Unknown facet '#{key}'") unless facet
        facet
      end

      def facet(definition, options = {}, &block)
        Facets.error("Unknown definition form '#{definition.inspect}'") unless (definition.is_a?(Symbol) || (definition.is_a?(Hash) && 1 == definition.size))
        key = (definition.is_a?(Hash) ? definition.keys[0] : definition).to_sym
        required_facets = definition.is_a?(Hash) ? definition.values[0] : []
        Reality::Facets::Facet.new(self, key, {:required_facets => required_facets}.merge(options), &block)
      end

      def facet_keys
        facet_map.keys
      end

      def facets
        facet_map.values
      end

      def target_manager
        @target_manager ||= Reality::Facets::TargetManager.new(self)
      end

      private

      def register_facet(facet)
        Facets.error("Attempting to redefine facet #{facet.key}") if facet_map[facet.key.to_s]
        facet_map[facet.key.to_s] = facet
      end

      # Map a facet key to a map. The map maps types to extension classes
      def facet_map
        @facets ||= Reality::OrderedHash.new
      end
    end
  end
end
