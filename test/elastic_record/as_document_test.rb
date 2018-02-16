require 'helper'

class ElasticRecord::AsDocumentTest < MiniTest::Test
  def test_as_search_document
    Widget.new(id: '10', color: 'green').tap do |widget|
      assert_equal({"color" => "green"}, widget.as_search_document)
    end

    Widget.new(id: '10', color: '').tap do |widget|
      assert_equal({}, widget.as_search_document)
    end

    # Widget.new(id: '10', color: false).tap do |widget|
    #   assert_equal({"color" => false}, widget.as_search_document)
    # end
  end

  def test_as_partial_update_document
    widget = Widget.create(name: 'elmo', color: 'green')

    Widget.elastic_index.update_document widget.id, name: 'wilbur'

    widget.update! color: 'grey'

    assert_equal 1, Widget.elastic_search.filter(color: 'grey').count
    assert_equal 0, Widget.elastic_search.filter(name: 'elmo').count
  end

  class SpecialFieldsModel
    include TestModel

    class Author
      def as_search_document
        {name: 'Jonny'}
      end
    end

    self.doctype.mapping[:properties].update(
      author:     { type: :object },
      commenters: { type: :nested },
      meta:       { type: "object" }
    )

    def author
      Author.new
    end

    def commenters
      [Author.new, Author.new]
    end

    def meta
      { some: "value" }
    end
  end

  def test_as_search_document_with_special_fields
    doc = SpecialFieldsModel.new.as_search_document

    assert_equal({name: 'Jonny'}, doc[:author])
    assert_equal([{name: 'Jonny'}, {name: 'Jonny'}], doc[:commenters])
    assert_equal({some: 'value'}, doc[:meta])
  end
end
