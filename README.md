# ElasticRecord #
[![Build Status](https://secure.travis-ci.org/data-axle/elastic_record.png?rvm=2.0.0)](http://travis-ci.org/data-axle/elastic_record)
[![Code Climate](https://codeclimate.com/github/data-axle/elastic_record.png)](https://codeclimate.com/github/data-axle/elastic_record)

ElasticRecord is an Elasticsearch 7.x ORM.

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

Helpful Arel builders can be found at https://github.com/matthuhiggins/arelastic/blob/master/lib/arelastic/builders/queries.rb.

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

  def as_search_document(**)
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
  include ElasticRecord::Model

  elastic_index.mapping = {
    properties: {
      name: {type: "text"},
      status: {type: "keyword"}
    }
  }
end
```

### Inheritance

When one model inherits from another, ElasticRecord makes some assumptions about how the child index should be configured.  By default:

* `alias_name` - Same as parent
* `mapping` - Same as parent
* `settings` - Same as parent

These can all be overridden.  For instance, it might be desirable for the child documents to be in a separate index.

### Join fields
ElasticSearch supports declaring a join field that specifies a parent-child relationship between documents of different types in the same index ([docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/parent-join.html)).
ElasticRecord provides a short-(but not-so-short)-cut for declaring the mapping:

```ruby
class State
  include ElasticRecord::Model
end

class Country
  include ElasticRecord::Model

  has_es_children(
    children:   State,
    join_field: 'pick_a_name_for_the_join_field'
  )
end
```

`has_es_children` accepts an optional `name` argument, with a sane default. In the above example, it would default to `country`. The name can later be used to construct `has_parent` queries.
ElasticRecord will define a getter method with the same name as the value provided to `join_field` on both the parent and all children (and grandchildren).

The `children` argument expects a Class or, for complex nestings, an instance of `::ElasticRecord::Model::Joining::JoinChild.new`.  You can also pass an Array, each element of which is either a `Class` or a `::ElasticRecord::Model::Joining::JoinChild.new`.

`::ElasticRecord::Model::Joining::JoinChild.new` accepts additional, optional arguments:
* `name`: defaults to the snake case version of the value provided to `klass` (e.g. `state` in the example above). Can be used to construct `has_child` queries.
* `children`: Another instance of `::ElasticRecord::Model::Joining::JoinChild` or an Array of instances. Defaults to an empty Array.  Theoretically, an arbitrary number of layers of parent-child joins can be achieved this way.
* `parent_id_accessor`: Determines how the ID of the parent is retrieved. Can be a proc, which will be executed in the context of the child object, or a symbol corresponding to the name of a method defined on the child object.  In the above example, it would default to `country_id`.
* `parent_accessor`: Determines how the parent is retrieved. Can be a proc, which will be executed in the context of the child object, or a symbol corresponding to the name of a method defined on the child object.  In the above example, it would default to `country`.  The is used to retrieve routing for multi-layered parent-child joins.
Notes:
* Creating, deleting and updating mapping on the index must be handled via the Top-Level parent.  Running `rake index:create CLASS=State` has no effect.
* The `load_from_source` configuration is not currently supported for indices with a join field.

### Load Documents from Source

To fetch documents without an additional request to a backing ActiveRecord database you can load the documents from `_source`.

```ruby
Product.elastic_index.loading_from_source do
  Product.elastic_search.filter(name: "Pizza")
end

```

Call `load_from_source!` to configure an index without ActiveRecord. Finder methods will be
delegated to the ElasticRecord module.

```ruby
class Product
  include ActiveModel::Model
  include ElasticRecord::Record
  elastic_index.load_from_source!
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
Product.elastic_index.update_mapping     # Update the elastic search mapping of the current index
```


## Development

```bash
# Setup the database
$ cp test/dummy/.env.example test/dummy/.env
$ bundle exec rake app:db:prepare app:index:reset
$ bundle exec rake app:db:prepare RAILS_ENV=test

# Run tests
$ bundle exec rake
```
