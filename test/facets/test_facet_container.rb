require File.expand_path('../../helper', __FILE__)

class Reality::Facets::TestFacetContainer < Reality::TestCase
  class Component < Reality.base_element(:name => true)
  end

  class Component2 < Reality.base_element(:name => true)
  end

  def test_basic_operation

    assert_equal false, TestFacetContainer.facet_by_name?(:gwt)
    assert_equal false, TestFacetContainer.facet?(:gwt)
    assert_equal false, TestFacetContainer.facet_by_name?(:gwt_rpc)
    assert_equal false, TestFacetContainer.facet?(:gwt_rpc)
    assert_equal [], TestFacetContainer.facet_keys
    assert_equal 0, TestFacetContainer.facets.size

    assert_raise_message("Unknown facet 'gwt'") { TestFacetContainer.facet_by_name(:gwt) }
    assert_raise_message("Unknown facet 'gwt_rpc'") { TestFacetContainer.facet_by_name(:gwt_rpc) }

    # Make sure we can add targets
    TestFacetContainer.target_manager.target(Component, :component)

    TestFacetContainer.facet(:gwt)

    # targets should be locked after first facet defined
    assert_raise_message('Attempting to define target component when targets have been locked.') do
      TestFacetContainer.target_manager.target(Component, :component)
    end

    assert_equal true, TestFacetContainer.facet_by_name?(:gwt)
    assert_equal true, TestFacetContainer.facet?(:gwt)
    assert_equal false, TestFacetContainer.facet_by_name?(:gwt_rpc)
    assert_equal false, TestFacetContainer.facet?(:gwt_rpc)
    assert_equal %w(gwt), TestFacetContainer.facet_keys
    assert_equal 1, TestFacetContainer.facets.size

    assert_raise_message("Unknown facet 'gwt_rpc'") { TestFacetContainer.facet_by_name(:gwt_rpc) }

    assert_equal TestFacetContainer, TestFacetContainer.facet_by_name(:gwt).facet_container
    assert_equal :gwt, TestFacetContainer.facet_by_name(:gwt).key
    assert_equal [], TestFacetContainer.facet_by_name(:gwt).required_facets
    assert_equal [], TestFacetContainer.facet_by_name(:gwt).suggested_facets

    TestFacetContainer.facet(:gwt_rpc => [:gwt])

    assert_equal true, TestFacetContainer.facet_by_name?(:gwt)
    assert_equal true, TestFacetContainer.facet?(:gwt)
    assert_equal true, TestFacetContainer.facet_by_name?(:gwt_rpc)
    assert_equal true, TestFacetContainer.facet?(:gwt_rpc)
    assert_equal %w(gwt gwt_rpc), TestFacetContainer.facet_keys
    assert_equal 2, TestFacetContainer.facets.size

    assert_equal TestFacetContainer, TestFacetContainer.facet_by_name(:gwt_rpc).facet_container
    assert_equal :gwt_rpc, TestFacetContainer.facet_by_name(:gwt_rpc).key
    assert_equal [:gwt], TestFacetContainer.facet_by_name(:gwt_rpc).required_facets
    assert_equal [], TestFacetContainer.facet_by_name(:gwt_rpc).suggested_facets

    assert_raise_message('Attempting to redefine facet gwt') { TestFacetContainer.facet(:gwt) }

    assert_raise_message("Unknown definition form '{:x=>:y, :z=>1}'") { TestFacetContainer.facet(:x => :y, :z => 1) }
  end
end
