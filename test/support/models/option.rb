class Option
  include TestModel

  define_attributes [:name, :widget_id]

  searches_many :options

  self.elastic_index.mapping[:properties].update(
    name: {
      type: 'multi_field',
      fields: {
        name: {type: 'string', index: 'not_analyzed'},
        analyzed: {type: 'string', index: 'analyzed'}
      }
    },
    widget_id: {
      type: 'string', index: 'not_analyzed'
    }
  )

  class << self
    def anon(&block)
      Class.new(self) do
        def self.name
          'Option'
        end

        instance_eval(&block)
      end
    end

    def _test_cache
      @_test_cache ||= []
    end

    def find(ids)
      ids.map { |id| _test_cache.detect { |m| m.id.to_s == id.to_s } || new(id: id, color: 'red') }
    end
  end

  def initialize(*args)
    super
    self.class._test_cache << self
  end

  def widget=(other)
    self.widget_id = other.id
  end
end
