require 'helper'

class ElasticRecord::CallbacksTest < MiniTest::Test
  def test_added_to_index
    widget = Widget.new id: '10', color: 'green'
    refute Widget.elastic_index.record_exists?(widget.id)

    widget.save

    assert Widget.elastic_index.record_exists?(widget.id)
  end

  def test_not_added_to_index_if_not_dirty
    widget = Widget.new id: '10', color: 'green'
    widget.changed_attributes.clear

    widget.save

    refute Widget.elastic_index.record_exists?(widget.id)
  end

  def test_deleted_from_index
    widget = Widget.new id: '10', color: 'green'
    Widget.elastic_index.index_document(widget.id, widget.as_search)

    assert Widget.elastic_index.record_exists?(widget.id)

    widget.destroy

    refute Widget.elastic_index.record_exists?(widget.id)
  end

  class DisablingModel
    include TestModel

    define_attributes [:height]

    self.elastic_index.mapping[:properties].update(
      height: {
        type: 'keyword'
      }
    )

    def as_search
      raise StandardError.new("Should never be called!")
      super
    end
  end

  # Does not belong in this test
  def test_disabled_skip_document
    DisablingModel.elastic_index.disable!

    model = DisablingModel.new id: '5', height: '9 feets'
    model.save

    refute Widget.elastic_index.record_exists?(model.id)
  end
end
