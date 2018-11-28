require 'helper'

class ElasticRecord::IndexTest < MiniTest::Test
  def test_copy
    copied = index.dup

    refute_equal copied.settings.object_id, index.settings.object_id
  end

  def test_alias_name
    assert_equal 'widgets', index.alias_name
  end

  def test_disable
    index.disable!

    assert index.disabled
  end

  def test_enable
    index.disable!
    index.enable!

    refute index.disabled
  end

  def test_loading_from_source
    index.loading_from_source do
      assert index.load_from_source
    end
    refute index.load_from_source
  end

  def test_delegations_when_loading_from_source
    project = Project.new(name: 'Something')
    Project.elastic_index.index_record(project)

    found_project = Project.first
    assert_equal 'Something', found_project.name
    assert_equal 'Something', Project.find(found_project.id).name
  end

  private

    def index
      @index ||= ElasticRecord::Index.new(Widget)
    end
end
