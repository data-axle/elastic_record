require 'helper'

class ElasticRecord::AsDocumentTest < MiniTest::Test
  def test_as_search_document
    Widget.new(color: 'green').tap do |widget|
      assert_equal({"color" => "green"}, widget.as_search_document)
    end

    Widget.new(color: '').tap do |widget|
      assert_equal({}, widget.as_search_document)
    end
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
    attr_accessor :meta, :book_length

    class Author
      include TestModel
      attr_accessor :name, :salary_estimate
    end

    self.doctype.mapping[:properties].update(
      author:      {
        type: :object,
        properties: {
          name: { type: :string },
          salary_estimate: { type: :integer_range }
        }
      },
      commenters:  {
        type: :nested,
        properties: {
          name: { type: :string }
        }
      },
      meta:        { type: "object" },
      book_length: { type: :integer_range }
    )

    def author
      Author.new(name: 'Jonny', salary_estimate: 250..Float::INFINITY)
    end

    def commenters
      [Author.new(name: 'Jonny'), Author.new(name: 'Jonny')]
    end
  end

  def test_as_search_document_with_special_fields
    record = SpecialFieldsModel.new(meta: { some: "value" })

    doc = record.as_search_document

    assert_equal({name: 'Jonny', salary_estimate: { 'gte' => 250, 'lte' => nil }}, doc[:author])
    assert_equal([{name: 'Jonny'}, {name: 'Jonny'}], doc[:commenters])
    assert_equal({some: 'value'}, doc[:meta])
  end

  def test_as_search_document_with_range_fields
    record = SpecialFieldsModel.new(book_length: 250..500)
    doc = record.as_search_document
    assert_equal({ "gte" => 250, "lte" => 500 }, doc[:book_length])

    record = SpecialFieldsModel.new(book_length: -Float::INFINITY..500)
    doc = record.as_search_document
    assert_equal({ "gte" => nil, "lte" => 500 }, doc[:book_length])

    record = SpecialFieldsModel.new(book_length: 250..Float::INFINITY)
    doc = record.as_search_document
    assert_equal({ "gte" => 250, "lte" => nil }, doc[:book_length])
  end

  def test_as_search_document_with_invalid_range_fields
    record = SpecialFieldsModel.new(book_length: 500..250)
    invalid_elasticsearch_doc = record.as_search_document
    assert_equal({ "gte" => 500, "lte" => 250 }, invalid_elasticsearch_doc[:book_length])
  end
end
