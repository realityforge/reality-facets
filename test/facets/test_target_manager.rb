require File.expand_path('../../helper', __FILE__)

class Reality::Facets::TestTargetManager < Reality::TestCase

  def test_target
    target_manager = Reality::Facets::TargetManager.new(TestFacetContainer)
    target1 = Reality::Facets::Target.new(target_manager, :repository, nil, {})

    assert_equal target_manager, target1.target_manager
    assert_equal :repository, target1.key
    assert_equal nil, target1.container_key
    assert_equal 'repositories', target1.access_method

    target2 = Reality::Facets::Target.new(target_manager, :data_module, :repository, {})

    assert_equal target_manager, target2.target_manager
    assert_equal :data_module, target2.key
    assert_equal :repository, target2.container_key
    assert_equal 'data_modules', target2.access_method

    target1 = Reality::Facets::Target.new(target_manager, :project, nil, :access_method => 'project_set')

    assert_equal target_manager, target1.target_manager
    assert_equal :project, target1.key
    assert_equal nil, target1.container_key
    assert_equal 'project_set', target1.access_method

    assert_raise_message('Attempting to redefine target project') { Reality::Facets::Target.new(target_manager, :project, nil, {}) }

    assert_raise_message("Target 'foo' defines container as 'bar' but no such target exists.") { Reality::Facets::Target.new(target_manager, :foo, :bar, {}) }
  end

  def test_target_manager_basic_operation

    target_manager = Reality::Facets::TargetManager.new(TestFacetContainer)

    assert_equal false, target_manager.is_target_valid?(:project)
    assert_equal [], target_manager.target_keys
    assert_equal false, target_manager.target_by_key?(:project)

    target_manager.target(:project)

    assert_equal true, target_manager.is_target_valid?(:project)
    assert_equal [:project], target_manager.target_keys
    assert_equal true, target_manager.target_by_key?(:project)
    assert_equal 1, target_manager.targets.size
    assert_equal :project, target_manager.targets[0].key

    target_manager.target(:component, :project, :access_method => 'comps')

    assert_equal true, target_manager.is_target_valid?(:component)
    assert_equal true, target_manager.target_by_key?(:component)
    assert_equal 2, target_manager.targets.size
    target = target_manager.target_by_key(:component)
    assert_equal :component, target.key
    assert_equal :project, target.container_key
    assert_equal 'comps', target.access_method

    assert_equal 1, target_manager.targets_by_container(:project).size
    assert_equal :component, target_manager.targets_by_container(:project)[0].key

    assert_raise_message("Can not find target with key 'foo'") { target_manager.target_by_key(:foo) }
  end
end
