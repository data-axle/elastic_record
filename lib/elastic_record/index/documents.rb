module ElasticRecord
  class Index
    module Documents
      def index_record(record, index_name = nil)
        index_name ||= alias_name
        document = record.respond_to?(:as_search) ? record.as_search : record.default_as_search

        connection.index(document, id: record.id, index: index_name)
        # json_put "#{index_name}/#{type}/#{record.id}", document
      end
      
      def delete_record(record, index_name = nil)
        index_name ||= alias_name

        json_delete "#{index_name}/#{type}/#{record.id}"
      end

      def record_exists?(id)
        !connection.get(id).nil?
      end

      def bulk(batch)
        connection.bulk do
          batch.each do |record|
            index_record(record)
          end
        end
      end
    end
  end
end