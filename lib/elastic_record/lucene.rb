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

      # Returns a lucene query that works like GMail
      def match_phrase(query, fields, &block)
        return if query.blank?

        words = split_phrase_into_words(query)

        words.map do |word|
          if word =~ /^(\w+):(.+)$/ && fields.include?($1)
            match_word $2, [block_given? ? yield($1) : $1]
          else
            match_word word, (block_given? ? fields.map(&block) : fields)
          end
        end.join(' AND ')
      end

      # Performs a prefix match on the word:
      # 
      # ElasticRecord::Lucene.match_word('blue', ['color', 'name'])
      #   => (color:blue* OR name:blue*)
      # 
      # In the case that the word has special characters, it is wrapped in quotes:
      # 
      # ElasticRecord::Lucene.match_word('A&M', ['name'])
      #   => (name:"A&M")
      def match_word(word, fields)
        if word =~ / / || word =~ ESCAPE_REGEX
          word = "\"#{word.gsub('"', '')}\""
        else
          word = "#{word}*"
        end

        or_query = fields.map do |field|
          "#{field}:#{word}"
        end.join(' OR ')

        "(#{or_query})"
      end

      private
        # Converts a sentence into the words:
        # 
        # split_phrase_into_words('his "blue fox"')
        # => ['his', 'blue fox']
        def split_phrase_into_words(phrase)
          # If we have an odd number of double quotes,
          # add a double quote to the end so that shellwords
          # does not crap out.
          if phrase.count('"') % 2 == 1
            phrase = "#{phrase}\""
          end

          Shellwords::shellwords phrase.gsub("'", "\"'\"")
        end
    end
  end
end