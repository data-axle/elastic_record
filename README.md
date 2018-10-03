# ElasticRecord #
[![Build Status](https://secure.travis-ci.org/data-axle/elastic_record.png?rvm=2.0.0)](http://travis-ci.org/data-axle/elastic_record)
[![Code Climate](https://codeclimate.com/github/data-axle/elastic_record.png)](https://codeclimate.com/github/data-axle/elastic_record)

ElasticRecord is an Elasticsearch 6.x ORM.

## Setup ##

Include ElasticRecord into your model:

```ruby
class Product < ActiveRecord::Base
  include ElasticRecord::Model
end
```

### Connection ###

There are two ways to set up which server to connect to:

```ruby
# config/initializers/elastic_search.rb
ElasticRecord.configure do |config|
  config.servers = "es1.example.com:9200"
end
```

```yaml
# config/elasticsearch.yml:
development:
  servers: es1.example.com:9200
  timeout: 10
  retries: 2
```

## Search API ##

ElasticRecord adds the method 'elastic_search' to your models. It works similar to active_record scoping:

```ruby
search = Product.elastic_search
```

### Filtering ###

If a simple hash is passed into filter, a term or terms query is created:

```ruby
search.filter(color: 'red')         # Creates a 'term' filter
search.filter(color: %w(red blue))  # Creates a 'terms' filter
search.filter(color: nil)           # Creates a 'must not exist' filter
```

If a hash containing hashes is passed into filter, it is used directly as a filter DSL expression:

```ruby
search.filter(prefix: { name: "Sca" }) # Creates a prefix filter
```

An Arelastic object can also be passed in, working similarily to Arel:

```ruby
# Name starts with 'Sca'
search.filter(Product.arelastic[:name].prefix("Sca"))

# Name does not start with 'Sca'
search.filter(Product.arelastic[:name].prefix("Sca").negate)

# Size is greater than 5
search.filter(Product.arelastic[:size].gt(5))
```

Helpful Arel builders can be found at https://github.com/matthuhiggins/arelastic/blob/master/lib/arelastic/builders/filter.rb.

### Querying ###

To create a query string, pass a string to search.query:

```ruby
search.query("red AND fun*") # Creates {query_string: {"red AND fun*"}}
```

Complex queries are done using either a hash or an arelastic object:

```ruby
search.query(match: {description: "amazing"})
```

### Ordering ###

```ruby
search.order(:price)          # sort by price
search.order(:color, :price)  # sort by color, then price
search.order(price: :desc)    # sort by price in descending order
```

### Offsets and Limits ###

To change the 'size' and 'from' values of a query, use offset and limit:

```ruby
search.limit(40).offset(80)   # Creates a query with {size: 40, from: 80}
```

### Aggregations ###

Aggregations are added with the aggregate method:

```ruby
search.aggregate('popular_colors' => {'terms' => {'field' => 'color'}})
```

Results are retrieved at query time within `aggregations`:

```ruby
search = search.aggregate('popular_colors' => {'terms' => {'field' => 'color'}})
search.aggregations['popular_colors'].buckets
```

### Getting Results ###

A search object behaves similar to an active_record scope, implementing a few methods of its own and delegating the rest to Array, and your class.

```ruby
search.count        # Return the number of search results
search.first        # Limit results to 1 and return the first result or nil
search.find(id)     # Add an ids filter to the existing query
search.as_elastic   # Return the json hash that will be sent to elastic search.
```

The search object behaves like an array when necessary:

```ruby
search.each do |product|
  ...
end
```

Class methods can be executed within scopes:

```ruby
class Product
  def self.increase_prices
    all.each do { |product| product.increment(:price, 10) }
  end
end

# Increase the price of all red products by $10.
Product.filter(color: 'red').increase_prices
```

## Percolators ##

ElasticRecord supports representing query documents as a model.  Queries are registered and unregistered as query models are created and destroyed.

First, include `ElasticRecord::PercolatorModel` into your model.  Specify the target model to percolate and how the model should be indexed as an ElasticSearch query.

```ruby
class ProductQuery
  include ElasticRecord::PercolatorModel

  self.percolates_model = Product

  def as_search_document
    Product.filter(status: status).as_elastic
  end
end
```

Use the `percolate` method to find records with queries that match.

```
  product = Product.new(price: 5.99)
  matching_product_queries = ProductQuery.percolate(product)
```

## Index Configuration

To avoid elasticsearch dynamically mapping fields, you can directly configure `elastic_index.mapping`
and `elastic_index.settings`:

```ruby
class Product
  elastic_index.mapping = {
    properties: {
      name: {type: "text"},
      status: {type: "keyword"}
    }
  }
end
```

Mapping types will be removed in ElasticSearch 7.x.  To rename the default mapping type (`_doc`), use `elastic_index.mapping_type`:

```ruby
class Product
  elastic_index.mapping_type = 'product'
end
```

### Load Documents from Source

To fetch documents without an additional request to a backing ActiveRecord database you can load the documents from `_source`.

```ruby
Product.elastic_index.loading_from_source do
  Product.elastic_search.filter(name: "Pizza")
end

```

Use `elastic_index.load_from_source = true` to configure an index without ActiveRecord.

```ruby
class Product
  include ActiveModel::Model
  include ElasticRecord::Record

  self.elastic_index.load_from_source = true
end
```

### Index Management ###

If you need to manage multiple indexes via the rake tasks, you will need to declare them explicitly:

```ruby
ElasticRecord.configure do |config|
  config.model_names = %w(Product Order Location)
end
```

Create the index:

```ruby
rake index:create CLASS=Product
```

### Index Admin Functions ###

Core and Index APIs can be accessed with Product.elastic_index. Some examples include:

```ruby
Product.elastic_index.create_and_deploy  # Create a new index
Product.elastic_index.reset              # Delete related indexes and deploy a new one
Product.elastic_index.refresh            # Call the refresh API
Product.elastic_index.get_mapping        # Get the index mapping defined by elastic search
```
