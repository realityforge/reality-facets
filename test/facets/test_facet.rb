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

    facet_gwt = Reality::Facets::Facet.new(TestFacetContainer, :gwt)
    Reality::Facets::Facet.new(TestFacetContainer, :gwt_rpc, :required_facets => [:gwt])

    facet_imit = Reality::Facets::Facet.new(TestFacetContainer, :imit, :suggested_facets => [:gwt_rpc]) do |f|
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

    assert_equal false, facet_gwt.enhanced?(Project)
    assert_equal false, facet_gwt.enhanced?(Component)
    assert_equal true, facet_imit.enhanced?(Project)
    assert_equal true, facet_imit.enhanced?(Component)

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
    assert_equal :imit, project.imit.facet_key
    assert_equal :project, project.imit.target_key
    assert_equal :imit, project.imit.class.facet_key
    assert_equal :project, project.imit.class.target_key

    # These methods all test that FacetModule has been mixed in.
    assert_equal 'GwtMyProject', project.facet(:imit).name
    assert_equal true, project.facet_enabled?(:imit)

    assert_equal [:gwt, :gwt_rpc, :imit], project.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :imit], component.enabled_facets

    assert_equal :imit, component.imit.facet_key
    assert_equal :component, component.imit.target_key
    assert_equal :imit, component.imit.class.facet_key
    assert_equal :component, component.imit.class.target_key

    # Ensure there is a link back to the container using inverse_access_method
    assert_equal project, project.imit.project
    assert_equal project, project.imit.parent
    assert_equal component, component.imit.comp
    assert_equal component, component.imit.parent
  end

  class Component2 < Reality.base_element(:name => true, :container_key => :project, :pre_config_code => 'Reality::TestCase::TestFacetContainer.target_manager.apply_extension(self)')
  end

  class Project2 < Reality.base_element(:name => true, :pre_config_code => 'Reality::TestCase::TestFacetContainer.target_manager.apply_extension(self)')
    def component(name, options = {}, &block)
      component_map[name.to_s] = Component2.new(self, name, options, &block)
    end

    def components
      component_map.values
    end

    def component_map
      @component_map ||= {}
    end
  end

  module MyExtensionModule
    def hello_message
      'yo'
    end
  end

  def test_common_extension_modules

    assert_equal false, TestFacetContainer.facet_by_name?(:gwt)

    TestFacetContainer.target_manager.target(Project2, :project)
    TestFacetContainer.target_manager.target(Component2,
                                             :component,
                                             :project)


    assert_equal [], TestFacetContainer.facet_extensions
    TestFacetContainer.facet_extension(MyExtensionModule)
    assert_equal [MyExtensionModule], TestFacetContainer.facet_extensions

    Reality::Facets::Facet.new(TestFacetContainer, :gwt) do |f|
      f.enhance(Project2) do
        def name
          "Gwt#{project.name}"
        end
      end
    end

    project = Project2.new(:MyProject) do |p|
      p.enable_facets(:gwt)
      p.component(:MyComponent)
    end
    component = project.components[0]

    assert_equal true, project.gwt?
    assert_equal 'GwtMyProject', project.gwt.name
    assert_equal 'yo', project.gwt.hello_message
    assert_equal false, component.respond_to?(:gwt)
  end
end
