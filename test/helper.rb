$:.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'test/unit/assertions'
require 'reality/facets'

class Reality::TestCase < Minitest::Test
  include Test::Unit::Assertions

  module TestFacetContainer
    class << self
      include Reality::Facets::FacetContainer

      def reset
        facet_map.clear
      end
    end
  end

  def setup
    TestFacetContainer.reset
  end
end
