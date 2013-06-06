require 'helper'

class ElasticRecord::Index::ManageTest < MiniTest::Spec
  class Felon
    include TestModel
  end

  def setup
    super
    Felon.elastic_index.delete_all
  end

  def test_create
    assert !index.exists?('felons_foo')

    index.create 'felons_foo'

    assert index.exists?('felons_foo')
  end

  def test_exists
    index.create 'felons_foo'

    assert index.exists?('felons_foo')
    assert !index.exists?('felons_bar')
  end

  def test_type_exists
    index.create 'felons_foo'

    assert index.type_exists?('felons_foo')
    assert !index.type_exists?('felons_bar')
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

  def test_close
    index.create 'felons_foo'
    index.close 'felons_foo'

    # test system fails for me
    index.refresh
  end

  def test_reopen
    index.create 'felons_foo'
    index.close 'felons_foo'
    index.open 'felons_foo'

    # test system fails for me
    index.refresh
  end


  private

    def index
      @index ||= Felon.elastic_index
    end
end