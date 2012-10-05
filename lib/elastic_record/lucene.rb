require 'shellwords'

module ElasticRecord
  class Lucene
    # Special characters:
    # + - && || ! ( ) { } [ ] ^ " ~ * ? : \
    ESCAPE_REGEX = /(\+|-|&&|\|\||!|\(|\)|{|}|\[|\]|`|"|~|\?|:|\\)/

    class << self
      def escape(query)
        query.gsub(ESCAPE_REGEX, "\\\\\\1")
      end

      # Returns a lucene query that works like G
      def smart_query(query, fields)
        return if query.blank?

        words = Shellwords::shellwords(query)

        words.map do |word|
          if word =~ /^(\w+):(.+)$/ && fields.include?($1)
            match_word $2, [$1]
          else
            match_word word, fields
          end
        end.join(' AND ')
      end

      def match_word(word, fields)
        word = escape(word)
        if word =~ / /
          word = "\"#{word}\""
        else
          word = "#{word}*"
        end

        or_query = fields.map { |field| "#{field}:#{word}" }.join(' OR ')

        "(#{or_query})"
      end
    end
  end
end