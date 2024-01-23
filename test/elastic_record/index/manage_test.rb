require 'helper'

class ElasticRecord::Index::ManageTest < Minitest::Test
  class Felon
    include TestModel
  end

  def setup
    super
    index.delete('felons_foo') rescue nil
    index.delete('felons_default') rescue nil
    index.delete('felons_override') rescue nil
  end

  def test_create
    assert !index.exists?('felons_foo')

    index.create 'felons_foo'

    assert index.exists?('felons_foo')
  end

  def test_create_with_overrides
    old_settings = ElasticRecord::Config.default_index_settings
    ElasticRecord::Config.default_index_settings = {
      number_of_replicas: '2'
    }
    index.remove_instance_variable('@settings') if index.instance_variable_defined?('@settings')
    index.create 'felons_default'
    assert_equal '2', index_settings('felons_default')['index']['number_of_replicas']
    index.create 'felons_override', setting_overrides: { number_of_replicas: 4 }
    assert_equal '4', index_settings('felons_override')['index']['number_of_replicas']
  ensure
    ElasticRecord::Config.default_index_settings = old_settings
    index.remove_instance_variable('@settings') if index.instance_variable_defined?('@settings')
  end

  def test_exists
    index.create 'felons_foo'

    assert index.exists?('felons_foo')
    assert !index.exists?('felons_bar')
  end

  def test_deploy
    index.create 'felons_foo'

    assert index.aliased_names.empty?
    index.deploy 'felons_foo'

    assert_equal ['felons_foo'], index.aliased_names
  end

  def test_deploy_when_already_deployed
    index.create 'felons_foo'
    index.deploy 'felons_foo'

    index.deploy 'felons_foo'

    assert_equal ['felons_foo'], index.aliased_names
  end

  private

    def index
      @index ||= Felon.elastic_index
    end

    def index_settings(index_name)
      Felon.elastic_connection.json_get("/#{index_name}/_settings")[index_name]['settings']
    end
end
