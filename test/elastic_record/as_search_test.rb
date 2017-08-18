require 'helper'

class ElasticRecord::AsSearchTest < MiniTest::Test
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

  def test_as_dirty_search
    Widget.new(id: '10', color: 'green').tap do |widget|
      assert_equal({'color' => 'green'}, widget.as_partial_update_document)
    end

    Widget.new(id: '10').tap do |widget|
      assert_equal({}, widget.as_partial_update_document)
    end

    Widget.new(id: '10', color: '').tap do |widget|
      assert_equal({'color' => nil}, widget.as_partial_update_document)
    end
  end

  class SpecialFieldsModel
    include TestModel

    class Author
      def as_search
        {name: 'Jonny'}
      end
    end

    self.doctype.mapping[:properties].update(
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
end
