require 'helper'

class ElasticRecord::FromSearchHitsTest < MiniTest::Test
  def setup
    super
    @project = Project.new(
      name: 'foo',
      estimated_start_date: Date.new(2019, 1, 1)..Date.new(2019, 2, 1),
      team_members: team_members,
      manager: manager
    )
    Project.elastic_index.index_record(@project)
  end

  def teardown
    Project.elastic_index.delete_by_query query: { match_all: {} }
  end

  def test_ranges
    document = Project.elastic_relation.first

    assert_equal 'foo', document.name
    assert_equal @project.estimated_start_date, document.estimated_start_date
  end

  def test_nested_ranges
    document = Project.elastic_relation.first
    team_members = document.team_members.sort_by { |member| member['name'] }

    assert_equal 26..29, team_members.first['estimated_age']
    assert_equal 25..30, team_members.second['estimated_age']
  end

  def test_object_ranges
    document = Project.elastic_relation.first

    assert_equal 25..30, document.manager['estimated_age']
  end

  private

    def manager
      Project::TeamMember.new(
        name: 'Fred',
        estimated_age: 25..30
      )
    end

    def team_members
      [
        Project::TeamMember.new(name: 'John', estimated_age: 25..30),
        Project::TeamMember.new(name: 'Jill', estimated_age: 26..29)
      ]
    end
end
