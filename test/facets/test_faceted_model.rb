require File.expand_path('../../helper', __FILE__)

class Reality::Facets::TestFacetedModel < Reality::TestCase
  class Attribute < Reality.base_element(:name => true, :container_key => :entity)
    def qualified_name
      "#{entity.qualified_name}.#{name}"
    end
  end

  class Entity < Reality.base_element(:name => true, :container_key => :repository)
    def qualified_name
      "#{repository.name}.#{name}"
    end

    def attribute(name, options = {}, &block)
      attribute_map[name.to_s] = Attribute.new(self, name, options, &block)
    end

    def attributes
      attribute_map.values
    end

    def attribute_map
      @attribute_map ||= {}
    end
  end

  class Repository < Reality.base_element(:name => true)
    def entity(name, options = {}, &block)
      entity_map[name.to_s] = Entity.new(self, name, options, &block)
    end

    def entities
      entity_map.values
    end

    def entity_map
      @entity_map ||= {}
    end
  end

  def test_activation
    TestFacetContainer.target_manager.target(Repository, :repository)
    TestFacetContainer.target_manager.target(Entity, :entity, :repository)
    TestFacetContainer.target_manager.target(Attribute, :attribute, :entity)

    TestFacetContainer.facet(:json)
    TestFacetContainer.facet(:jpa)
    TestFacetContainer.facet(:gwt)
    TestFacetContainer.facet(:gwt_rpc => [:gwt])
    TestFacetContainer.facet(:imit => [:gwt_rpc]) do |f|
      f.suggested_facets << :jpa
    end

    assert_equal 5, TestFacetContainer.facets.size

    repository = Repository.new(:MyRepo) do |r|
      TestFacetContainer.target_manager.apply_extension(r)

      r.enable_facet(:json)

      r.entity(:MyEntityA) do |e|
        TestFacetContainer.target_manager.apply_extension(e)
        e.attribute(:MyAttr1) do |a|
          TestFacetContainer.target_manager.apply_extension(a)
        end
        e.disable_facet(:json)
        e.attribute(:MyAttr2) do |a|
          TestFacetContainer.target_manager.apply_extension(a)
        end
      end

      r.entity(:MyEntityB) do |e|
        TestFacetContainer.target_manager.apply_extension(e)
      end
    end

    entity1 = repository.entities[0]
    attribute1 = entity1.attributes[0]
    attribute2 = entity1.attributes[1]
    entity2 = repository.entities[1]

    assert_equal [:json], repository.enabled_facets
    assert_equal [], entity1.enabled_facets
    assert_equal [:json], entity2.enabled_facets
    assert_equal [], attribute1.enabled_facets
    assert_equal [], attribute2.enabled_facets

    repository.enable_facet(:imit)
    assert_raise_message('Facet imit already enabled.') { repository.enable_facet(:imit) }

    assert_equal [:json, :gwt, :gwt_rpc, :jpa, :imit], repository.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :jpa, :imit], entity1.enabled_facets
    assert_equal [:json, :gwt, :gwt_rpc, :jpa, :imit], entity2.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :jpa, :imit], attribute1.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :jpa, :imit], attribute2.enabled_facets

    entity1.disable_facet(:gwt)

    assert_equal [:json, :gwt, :gwt_rpc, :jpa, :imit], repository.enabled_facets
    assert_equal [:jpa], entity1.enabled_facets
    assert_equal [:json, :gwt, :gwt_rpc, :jpa, :imit], entity2.enabled_facets
    assert_equal [:jpa], attribute1.enabled_facets
    assert_equal [:jpa], attribute2.enabled_facets

    entity1.enable_facet(:json)

    assert_equal [:json, :gwt, :gwt_rpc, :jpa, :imit], repository.enabled_facets
    assert_equal [:jpa, :json], entity1.enabled_facets
    assert_equal [:json, :gwt, :gwt_rpc, :jpa, :imit], entity2.enabled_facets
    assert_equal [:jpa, :json], attribute1.enabled_facets
    assert_equal [:jpa, :json], attribute2.enabled_facets

    repository.disable_facet(:json)

    assert_equal [:gwt, :gwt_rpc, :jpa, :imit], repository.enabled_facets
    assert_equal [:jpa], entity1.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :jpa, :imit], entity2.enabled_facets
    assert_equal [:jpa], attribute1.enabled_facets
    assert_equal [:jpa], attribute2.enabled_facets

    repository.enable_facets([:json])

    assert_equal [:gwt, :gwt_rpc, :jpa, :imit, :json], repository.enabled_facets
    assert_equal [:jpa, :json], entity1.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :jpa, :imit, :json], entity2.enabled_facets
    assert_equal [:jpa, :json], attribute1.enabled_facets
    assert_equal [:jpa, :json], attribute2.enabled_facets

    # No-op as all enabled
    repository.enable_facets([:json])

    assert_equal [:gwt, :gwt_rpc, :jpa, :imit, :json], repository.enabled_facets
    assert_equal [:jpa, :json], entity1.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :jpa, :imit, :json], entity2.enabled_facets
    assert_equal [:jpa, :json], attribute1.enabled_facets
    assert_equal [:jpa, :json], attribute2.enabled_facets

    assert_raise_message('Facet json already enabled.') { repository.enable_facets!([:json]) }

    # Try using brackets
    repository.disable_facets([:json, :imit])
    repository.enable_facets([:imit, :json])

    assert_equal [:gwt, :gwt_rpc, :jpa, :imit, :json], repository.enabled_facets
    assert_equal [:jpa, :gwt, :gwt_rpc, :imit, :json], entity1.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :jpa, :imit, :json], entity2.enabled_facets
    assert_equal [:jpa, :gwt, :gwt_rpc, :imit, :json], attribute1.enabled_facets
    assert_equal [:jpa, :gwt, :gwt_rpc, :imit, :json], attribute2.enabled_facets

    # Try using raw facet list
    repository.disable_facets(:json, :imit)
    repository.enable_facets(:imit, :json)

    assert_equal [:gwt, :gwt_rpc, :jpa, :imit, :json], repository.enabled_facets
    assert_equal [:jpa, :gwt, :gwt_rpc, :imit, :json], entity1.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :jpa, :imit, :json], entity2.enabled_facets
    assert_equal [:jpa, :gwt, :gwt_rpc, :imit, :json], attribute1.enabled_facets
    assert_equal [:jpa, :gwt, :gwt_rpc, :imit, :json], attribute2.enabled_facets

    # Try forcing
    repository.disable_facets(:json, :imit)
    repository.enable_facets!(:imit, :json)

    assert_equal [:gwt, :gwt_rpc, :jpa, :imit, :json], repository.enabled_facets
    assert_equal [:jpa, :gwt, :gwt_rpc, :imit, :json], entity1.enabled_facets
    assert_equal [:gwt, :gwt_rpc, :jpa, :imit, :json], entity2.enabled_facets
    assert_equal [:jpa, :gwt, :gwt_rpc, :imit, :json], attribute1.enabled_facets
    assert_equal [:jpa, :gwt, :gwt_rpc, :imit, :json], attribute2.enabled_facets
  end
end
