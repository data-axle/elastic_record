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

    Widget.elastic_index.update_document widget.id, { name: 'wilbur' }

    widget.update! color: 'grey', widget_part: { name: 'Doohicky' }

    assert_equal 1, Widget.elastic_search.filter(color: 'grey').count
    assert_equal 1, Widget.elastic_search.filter('widget_part.name' => 'Doohicky').count
    assert_equal 0, Widget.elastic_search.filter(name: 'elmo').count

    widget.widget_part = { name: nil }
    widget.save!

    assert_equal 1, Widget.elastic_search.filter('widget_part.name' => nil).count
  end

  class SpecialFieldsModel
    include TestModel
    define_attributes :author, :book_length, :commenters, :meta

    class Author
      include TestModel
      define_attributes :name, :salary_estimate

      elastic_index.mapping[:properties].update(
        'name' => { type: :string },
        'salary_estimate' => { type: :integer_range }
      )
    end

    elastic_index.mapping[:properties].update(
      'author' => {
        type: :object,
        properties: Author.elastic_index.mapping[:properties]
      },
      'commenters' => {
        type: :nested,
        properties: Author.elastic_index.mapping[:properties]
      },
      'meta' => { type: "object" },
      'book_length' => { type: :integer_range }
    )
  end

  def test_as_search_document_when_object_empty
    record = SpecialFieldsModel.new
    assert_equal({}, record.as_search_document)
  end

  def test_as_search_document_with_special_fields
    record = SpecialFieldsModel.new(meta: { some: "value" })
    record.author = SpecialFieldsModel::Author.new(name: 'Jonny', salary_estimate: (250..))
    record.commenters = [
      SpecialFieldsModel::Author.new(name: 'Jonny'),
      SpecialFieldsModel::Author.new(name: 'Jonny')
    ]

    doc = record.as_search_document

    expected_author = {
      'name' => 'Jonny',
      'salary_estimate' => { 'gte' => 250, 'lte' => nil }
    }
    assert_equal(expected_author, doc['author'])
    expected_commenter = { 'name' => 'Jonny' }
    assert_equal([expected_commenter, expected_commenter], doc['commenters'])
    assert_equal({ some: 'value'}, doc['meta'])
  end

  def test_as_search_document_with_range_fields
    record = SpecialFieldsModel.new(book_length: 250..500)
    doc = record.as_search_document
    assert_equal({ "gte" => 250, "lte" => 500 }, doc['book_length'])

    record = SpecialFieldsModel.new(book_length: -Float::INFINITY..500)
    doc = record.as_search_document
    assert_equal({ "gte" => nil, "lte" => 500 }, doc['book_length'])

    record = SpecialFieldsModel.new(book_length: (250..))
    doc = record.as_search_document
    assert_equal({ "gte" => 250, "lte" => nil }, doc['book_length'])
  end

  def test_as_search_document_with_invalid_range_fields
    record = SpecialFieldsModel.new(book_length: 500..250)
    invalid_elasticsearch_doc = record.as_search_document
    assert_equal({ "gte" => 500, "lte" => 250 }, invalid_elasticsearch_doc['book_length'])
  end

  def test_as_partial_update_document_with_special_fields
    record = SpecialFieldsModel.create
    record.author = SpecialFieldsModel::Author.new(name: 'Johnny')
    doc = record.as_partial_update_document

    expected_commenter = { 'name' => 'Johnny', 'salary_estimate' => nil }
    assert_equal expected_commenter, doc['author']
  end
end
