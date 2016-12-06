require File.expand_path('../../helper', __FILE__)

class Reality::Facets::TestFacet < Reality::TestCase
  class Component < Reality.base_element(:name => true, :container_key => :project, :pre_config_code => 'Reality::TestCase::TestFacetContainer.target_manager.apply_extension(self)')
  end

  class Project < Reality.base_element(:name => true, :pre_config_code => 'Reality::TestCase::TestFacetContainer.target_manager.apply_extension(self)')
    def component(name, options = {}, &block)
      component_map[name.to_s] = Component.new(self, name, options, &block)
    end

    def comps
      component_map.values
    end

    def component_map
      @component_map ||= {}
    end
  end

  def test_basic_operation

    assert_equal false, TestFacetContainer.facet_by_name?(:gwt)
    assert_equal false, TestFacetContainer.facet_by_name?(:gwt_rpc)
    assert_equal false, TestFacetContainer.facet_by_name?(:imit)

    TestFacetContainer.target_manager.target(Project, :project)
    TestFacetContainer.target_manager.target(Component,
                                             :component,
                                             :project,
                                             :access_method => :comps,
                                             :inverse_access_method => :comp)

    Reality::Facets::Facet.new(TestFacetContainer, :gwt)
    Reality::Facets::Facet.new(TestFacetContainer, :gwt_rpc, :required_facets => [:gwt])

    Reality::Facets::Facet.new(TestFacetContainer, :imit, :suggested_facets => [:gwt_rpc]) do |f|
      f.enhance(Project) do
        def name
          "Gwt#{project.name}"
        end
      end
      f.enhance(Component)
    end

    assert_equal true, TestFacetContainer.facet_by_name?(:gwt)
    assert_equal true, TestFacetContainer.facet_by_name?(:gwt_rpc)
    assert_equal true, TestFacetContainer.facet_by_name?(:imit)

    project = Project.new(:MyProject) do |p|
      p.enable_facets(:imit)
      p.component(:MyComponent)
    end
    component = project.comps[0]

    assert_equal true, project.gwt?
    assert_equal false, project.respond_to?(:gwt)
    assert_equal false, project.respond_to?(:facet_gwt)
    assert_equal true, project.gwt_rpc?
    assert_equal false, project.respond_to?(:gwt_rpc)
    assert_equal false, project.respond_to?(:facet_gwt_rpc)
    assert_equal true, project.imit?
    assert_equal true, project.respond_to?(:imit)
    assert_equal true, project.respond_to?(:facet_imit)
    assert_equal 'GwtMyProject', project.imit.name

    # These methods all test that FacetModule has been mixed in.
    assert_equal 'GwtMyProject', project.facet(:imit).name
    assert_equal true, project.facet_enabled?(:imit)

    assert_equal [:gwt, :gwt_rpc, :imit], project.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :imit], component.enabled_facets

    # Ensure there is a link back to the container using inverse_access_method
    assert_equal project, project.imit.project
    assert_equal component, component.imit.comp
  end
end
