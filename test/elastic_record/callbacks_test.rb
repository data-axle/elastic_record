require 'helper'

class ElasticRecord::CallbacksTest < MiniTest::Spec
  def setup
    super
    Widget.elastic_index.reset
  end

  def test_added_to_index
    widget = Widget.new id: '10', color: 'green'
    refute Widget.elastic_index.record_exists?(widget.id)

    widget.run_callbacks :save

    assert Widget.elastic_index.record_exists?(widget.id)
  end

  def test_deleted_from_index
    widget = Widget.new id: '10', color: 'green'
    Widget.elastic_index.index_document(widget.id, widget.as_search)

    assert Widget.elastic_index.record_exists?(widget.id)

    widget.run_callbacks :destroy

    refute Widget.elastic_index.record_exists?(widget.id)
  end
end