require 'yaml'
class BuildingManager
  attr_reader :list_buildings
  def initialize
    @list_buildings = YAML.load(File.open("./building_data.yml"))
  end

  def enumerate_available(company)
    list_available = []
    company_outlay = company.outlay
    company_research = company.research
    @list_buildings.each do |building|
      next if building.research > company_research
      next if building.outlay + company_outlay > company.honor
      next if building.name == "barrack"
      list_available << building
    end
    (company.list_buildings || []).each do |owned|
      break if owned.nil?
      list_available.delete_if { |ava| ava.name == owned.name }
    end
    list_available
  end

  def search_by_name(name)
    result = nil
    @list_buildings.each do |building|
      result = building if building.name == name
    end
    result
  end
end

class Building
  attr_reader :name, :outlay, :antipathy, :limit, :research
  def enable_labo_to_build
    @research = 20
  end
end
