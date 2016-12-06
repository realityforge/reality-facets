$:.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'test/unit/assertions'
require 'reality/facets'

class Reality::TestCase < Minitest::Test
  include Test::Unit::Assertions

  module TestFacetContainer
    extend Reality::Facets::FacetContainer
    class << self

      def reset
        facet_map.clear
        target_manager.reset_targets
        TestFacetContainer::FacetDefinitions.constants.each do |constant|
          TestFacetContainer::FacetDefinitions.send(:remove_const, constant)
        end if TestFacetContainer.const_defined?(:FacetDefinitions)
      end
    end
  end

  def setup
    TestFacetContainer.reset
  end
end
