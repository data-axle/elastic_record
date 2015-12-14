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

  def test_as_search
    Widget.new(id: '10', color: 'green').tap do |widget|
      assert_equal({"color" => "green"}, widget.as_search)
    end

    Widget.new(id: '10', color: '').tap do |widget|
      assert_equal({}, widget.as_search)
    end

    Widget.new(id: '10', color: false).tap do |widget|
      assert_equal({"color" => false}, widget.as_search)
    end
  end

  class SpecialFieldsModel
    include TestModel

    class Author
      def as_search
        {name: 'Jonny'}
      end
    end

    self.elastic_index.mapping[:properties].update(
      author: {
        type: :object
      },
      commenters: {
        type: :nested
      }
    )

    def author
      Author.new
    end

    def commenters
      [Author.new, Author.new]
    end
  end

  def test_as_search_with_special_fields
    doc = SpecialFieldsModel.new.as_search

    assert_equal({name: 'Jonny'}, doc[:author])
    assert_equal([{name: 'Jonny'}, {name: 'Jonny'}], doc[:commenters])
  end

  class DisablingModel
    include TestModel

    attr_accessor :called_as_search

    define_attributes [:height]

    self.elastic_index.mapping[:properties].update(
      'height' => {
        type: 'string', index: 'not_analyzed'
      }
    )

    def as_search
      @called_as_search = true
      super
    end

  end

  def test_disabled_skip_document
    DisablingModel.elastic_index.disable!

    model = DisablingModel.new id: '5', height: '9 feets'
    model.save

    refute Widget.elastic_index.record_exists?(model.id)
    refute model.called_as_search
  end
end