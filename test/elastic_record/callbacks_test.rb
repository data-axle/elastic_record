require 'helper'

class ElasticRecord::CallbacksTest < MiniTest::Test
  def test_added_to_index
    widget = Widget.new color: 'green'

    widget.save

    assert Widget.elastic_index.record_exists?(widget.id)
  end

  def test_not_added_to_index_if_not_dirty
    widget = Widget.create color: 'green'

    widget.elastic_index.delete_document(widget.id)

    widget.save
    assert_equal 0, Widget.elastic_search.count
  end

  def test_deleted_from_index
    widget = Widget.create color: 'green'
    assert Widget.elastic_index.record_exists?(widget.id)

    widget.destroy
    refute Widget.elastic_index.record_exists?(widget.id)
  end

  class DisablingModel
    include TestModel

    define_attributes :height

    self.elastic_index.mapping[:properties].update(
      height: {
        type: 'keyword'
      }
    )

    def as_search_document(**)
      raise StandardError.new("Should never be called!")
      super
    end
  end
end
