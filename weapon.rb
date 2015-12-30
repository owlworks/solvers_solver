class WeaponManager
  attr_reader :list_weapons

  def initialize
    @list_weapons = []
    #@list_weapons << Weapon.new("stungun", 1, 5, "armo")
    #@list_weapons << Weapon.new("assault_rifle", 1, 6, "armo")
    @list_weapons << Weapon.new("rpg", 3, 8, "armo")
    @list_weapons << Weapon.new("railgun", 6, 12, "tech_labo")
    #@list_weapons << Weapon.new("TRPG", 4, 14, "tech_labo")
  end

  def enumerate_available(company, hero)
    list_available = []
    list_buildings_name = company.enumerate_building_connecting_barrack
    @list_weapons.each do |weapon|
      list_buildings_name.each do |provider|
        list_available << weapon if provider == weapon.provider
      end
    end
    (hero.list_weapons || []).each do |owned|
      list_available.delete_if { |ava| ava.name == owned.name }
    end
    list_available
  end

  private

  def parse_list_name_buildings(company)
    list_buildings_name = []
    company.list_buildings.each do |building|
      break if building.nil?
      list_buildings_name << building.name
    end
    list_buildings_name.uniq!
    list_buildings_name
  end
end

class Weapon
  attr_accessor :outlay
  attr_reader :name, :int_effect, :provider
  def initialize(name, outlay, int_effect, provider)
    @name = name
    @outlay = outlay
    @int_effect = int_effect
    @provider = provider
  end
end
