require 'shellwords'

module ElasticRecord
  class Lucene
    # Special characters:
    # + - && || ! ( ) { } [ ] ^ " ~ * ? : \
    ESCAPE_REGEX = /(\+|-|&&|\|\||!|\(|\)|{|}|\[|\]|`|"|~\*|\?|:|\\)/

    class << self
      def escape(query)
        query.gsub(ESCAPE_REGEX, "\\\\\\1")
      end

      def query_words(query)
        # If we have an odd number of double quotes,
        # add a double quote to the end so that shellwords
        # does not crap out.
        if query.count('"') % 2 == 1
          query = "#{query}\""
        end

        Shellwords::shellwords query.gsub("'", "\"'\"")
      end

      # Returns a lucene query that works like GMail
      def smart_query(query, fields, &block)
        return if query.blank?

        words = query_words(query)

        words.map do |word|
          if word =~ /^(\w+):(.+)$/ && fields.include?($1)
            match_word $2, [$1], &block
          else
            match_word word, fields, &block
          end
        end.join(' AND ')
      end

      def match_word(word, fields, &block)
        if word =~ / / || word =~ ESCAPE_REGEX
          word = "\"#{word.gsub('"', '')}\""
        else
          word = "#{word}*"
        end

        or_query = fields.map do |field|
          field = yield(field) if block_given?
          "#{field}:#{word}"
        end.join(' OR ')

        "(#{or_query})"
      end
    end
  end
end