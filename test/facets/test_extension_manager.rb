require File.expand_path('../../helper', __FILE__)

class Reality::Facets::TestExtensionManager < Reality::TestCase

  module MyExtensionModule
  end

  module MySingletonExtensionModule
  end

  def test_basic_operation

    extension_manager = Reality::Facets::ExtensionManager.new
    assert_equal false, extension_manager.locked?

    assert_equal [], extension_manager.instance_extensions
    extension_manager.instance_extension(MyExtensionModule)
    assert_equal [MyExtensionModule], extension_manager.instance_extensions

    assert_equal [], extension_manager.singleton_extensions
    extension_manager.singleton_extension(MySingletonExtensionModule)
    assert_equal [MySingletonExtensionModule], extension_manager.singleton_extensions

    extension_manager.lock!

    assert_facet_error('Attempting to define instance extension Reality::Facets::TestExtensionManager::MyExtensionModule after extension manager is locked') do
      extension_manager.instance_extension(MyExtensionModule)
    end

    assert_facet_error('Attempting to define singleton extension Reality::Facets::TestExtensionManager::MySingletonExtensionModule after extension manager is locked') do
      extension_manager.singleton_extension(MySingletonExtensionModule)
    end
  end
end
