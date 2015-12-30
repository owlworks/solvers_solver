require 'pp'
require './mission.rb'
require './building.rb'
require './weapon.rb'
require './helper.rb'

class Company
  attr_reader :heros, :outlay, :b_reducting_final_mission
  attr_accessor :list_buildings, :bm, :mm, :wm, :honor, :antipathy,
                :research, :extend_level, :b_parse_info
  HEROS_DEFAULT_NAMES = %w(Alice Bob)
  LIST_JOBS = %w(Soldier Police Robot Hustler Engineer Scientist)
  BUILDING_THRESHOLDS = Array[2, 5, 7, 9, 10]

  def initialize(job)
    @sticked_job = job
    @mm = MissionManager.new
    @bm = BuildingManager.new
    @wm = WeaponManager.new
    @honor = 5
    @antipathy = 0
    @research = 0
    @heros = []
    @b_parse_info = true
    @extend_level = 0
    @b_reducting_final_mission = false
    @list_buildings = Array.new(BUILDING_THRESHOLDS.last)
    add_building(@bm.search_by_name("barrack"), 0)
  end

  def parse
    str_buildings = []
    (@list_buildings || []).each do |b|
      break if b.nil?
      str_buildings << b.name
    end
    puts "+-------------------------------------------------------"
    puts "|  Honor : #{@honor}   Antipathy : #{@antipathy}   Outlay : #{outlay}"
    puts "|  Research : #{@research}   ExtendLv : #{@extend_level} "
    puts "|  Building : #{str_buildings.join(', ')}"
    puts "+-------------------------------------------------------"
  end

  def confirm_mission(mission)
    case mission.decide_result
    when "triumph" then
      @honor += mission.result.reward_triumph
      @b_reducting_final_mission = true if mission.name == "mission10b"
    when "success" then @honor += mission.result.reward_success
    when "fail" then
      if mission.result.reward_fail - @heros.first.sociability >= 0
        @antipathy += mission.result.reward_fail - @heros.first.sociability
      end
    end
    @antipathy += mission.gained_antipathy
    @research += mission.gained_research
    @heros.first.exp += mission.gained_achive
    @heros.first.exp += 5 if @heros.first.skilled?("deep_learning")
  end

  def outlay
    outlay = 0
    (@list_buildings || []).each do |building|
      break if building.nil?
      outlay += building.outlay
    end

    @heros.each do |hero|
      (hero.list_weapons || []).each do |weapon|
        outlay += weapon.outlay
      end
    end
    outlay += @extend_level * 2
    outlay
  end

  def add_hero(num_room)
    list_die = Helper.roll_die(1)
    name = HEROS_DEFAULT_NAMES[@heros.length]
    job = LIST_JOBS[list_die[0] - 1] # 固定
    job = @sticked_job
    new_hero = Hero.new(name, job, num_room)
    new_hero.update_params([0, 0, 0, 0])
    @heros << new_hero
  end

  def enable_to_pay?(num_cost)
    return true if num_cost < @honor - outlay
  end

  def add_building(building, num_room = "")
    if num_room == ""
      @list_buildings.each_with_index do |building_owned, num_blank_room|
        if building_owned.nil?
          num_room = num_blank_room
          break
        end
      end
    end
    @list_buildings[num_room.to_i] = building
    # Processes when are built
    add_hero(num_room) if building.name == "barrack"
    @heros.first.sociability = 18 if building.name == "lobotomy"
    @research += 5 if building.name == "labo"
    DirectorAI.direct_divide_bonus(@heros.first, 3) if building.name == "dispensing_center"
    @heros.first.list_items << "apc" if building.name == "garage"
    @heros.first.list_items << "additional_battery" if building.name == "shelter"
    @heros.first.list_items << "w_drive" if building.name == "watanabe_drive"
    @honor += 4 if building.name == "pr_office"
  end

  def enable_to_extend?
    return false unless enable_to_pay?(2)
    return false if @extend_level >= 4
    true
  end

  def enumerate_building_connecting_barrack
    list_buildings = []
    list_buildings << @list_buildings[1].name unless @list_buildings[1].nil?
    list_buildings << @list_buildings[3].name unless @list_buildings[3].nil?
    list_buildings
  end

  def enable_to_build?
    b_enable = false
    num_buildings = 0
    @list_buildings.each do |building|
      if building.nil?
        break
      else
        num_buildings += 1
      end
    end
    b_enable = true if BUILDING_THRESHOLDS[@extend_level] > num_buildings
    b_enable
  end

  def gameover?
    b_gameover = false
    b_gameover = true if @antipathy > honor
    b_gameover
  end
end
