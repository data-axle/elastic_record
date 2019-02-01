require 'helper'

class ElasticRecord::FromSearchHitsTest < MiniTest::Test
  def setup
    super
    @project = Project.new(
      name: 'foo',
      estimated_start_date: Date.new(2019, 1, 1)..Date.new(2019, 2, 1),
      estimated_hours: 1..5,
      team_members: team_members,
      leader: leader
    )
    Project.elastic_index.index_record(@project)
  end

  def test_ranges
    document = Project.elastic_relation.search_hits.to_records.first

    assert_equal 'foo', document.name
    assert_equal @project.estimated_start_date, document.estimated_start_date
    assert_equal @project.estimated_hours, document.estimated_hours
  end

  def test_nested_ranges
    document = Project.elastic_relation.search_hits.to_records.first
    team_members = document.team_members.sort_by { |member| member['name'] }

    assert_equal 26..29, team_members.first['estimated_age']
    assert_equal 25..30, team_members.second['estimated_age']
  end

  def test_object_ranges
    document = Project.elastic_relation.search_hits.to_records.first

    expected = Date.new(2018, 1, 14)..Date.new(2018, 1, 21)
    assert_equal expected, document.leader['estimated_join_date']
  end

  private

    def leader
      Project::Leader.new(
        name: 'Fred',
        estimated_join_date: Date.new(2018, 1, 14)..Date.new(2018, 1, 21)
      )
    end

    def team_members
      [
        Project::TeamMember.new(name: 'John', estimated_age: 25..30),
        Project::TeamMember.new(name: 'Jill', estimated_age: 26..29)
      ]
    end
end
