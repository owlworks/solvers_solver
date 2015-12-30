require './weapon.rb'
require './helper.rb'
require 'yaml'

class MissionManager
  attr_reader :list_missions
  def initialize
    @list_missions = YAML.load(File.open("./mission_data.yml"))
    @list_missions.each do |mission|
      mission.set_def
      mission.list_approaches.each(&:set_def)
    end
  end
end

class Mission
  attr_accessor :name, :list_approaches, :result, :hero
  attr_reader :gained_achive, :gained_antipathy, :gained_research,
              :consume_stamina, :b_twice_effect, :num_weapon_app

  def set_def
    @gained_achive = 0
    @gained_antipathy = 0
    @gained_research = 0
    @consume_stamina = 0
    @b_twice_effect = false
    @b_twice_by_mutant_hero = false
  end

  def num_weapon_app
    num_app = 0
    @list_approaches.each do |app|
      num_app += 1 if app.b_use_weapon
    end
    num_app
  end

  def gain_achive_by_skill_app(apps_name, weapon_used = [])
    case apps_name
    when "sentry_gun"
      @gained_achive += weapon_used.int_effect
    when "outer_mec"
      @gained_achive += 8
      @gained_achive += 8 if @hero.list_items.include?("additional_battery")
    when "mutant_hero"
      @b_twice_by_mutant_hero = true
    end
  end

  def take_approach(approach, dice, weapon = [])
    @gained_achive += calc_gain_achive(approach, approach.achievement, dice)
    @gained_antipathy += calc_gain_antipathy(approach, approach.antipathy, dice)
    @gained_research += calc_gain_research(approach, approach.research, dice)
    @consume_stamina += calc_consume_stamina(approach, approach.stamina, dice)

    @b_twice_effect = true if approach.b_twice_effect
    if weapon != [] && approach.b_use_weapon
      @gained_achive += dice.to_i if @hero.list_items.include?("apc")
      @gained_achive += weapon.int_effect
    end
  end

  def calc_consume_stamina(approach, val, dice)
    consume_stamina = 0
    consume_stamina += calc_reflection(val, dice)
    approach_name = approach.name.split("-").first
    if approach_name == "weapon" && @hero.skilled?("marksman")
      consume_stamina -= 1 unless consume_stamina <= 0
    end
    if approach_name == "combat" && @hero.skilled?("judo")
      consume_stamina -= 1 unless consume_stamina <= 0
    end
    consume_stamina
  end

  def calc_gain_antipathy(approach, val, dice)
    antipathy = 0
    antipathy += calc_reflection(val, dice)
    approach_name = approach.name.split("-").first
    if approach_name == "plot" && @hero.skilled?("irresponsibility")
      antipathy = 0
    end
    antipathy
  end

  def calc_gain_research(approach, val, dice)
    research = 0
    research += calc_reflection(val, dice)
    approach_name = approach.name.split("-").first
    if approach_name == "experiment" && @hero.skilled?("science_method")
      research += 2
    end
    research
  end

  def calc_gain_achive(approach, val, dice)
    gain_achive = 0
    gain_achive += calc_reflection(val, dice)
    approach_name = approach.name.split("-").first
    if approach_name == "combat" && @hero.skilled?("hyper_reaction")
      gain_achive *= 2
    end
    if approach_name == "construction" && @hero.skilled?("one_night_castle")
      gain_achive *= 2
    end
    if approach_name == "experiment" && @hero.skilled?("science_method")
      gain_achive += 1
    end
    if approach_name == "experiment" && @hero.list_items.include?("w_drive")
      gain_achive += 6
    end
    gain_achive
  end

  def calc_reflection(val, dice)
    return 0 if val == ""
    reflection = Helper.parse_dice_signage(val, dice)
    reflection.to_i
  end

  def calc_achivement
    achive = @gained_achive
    achive *= 2 if @b_twice_effect
    achive *= 2 if @b_twice_by_mutant_hero
    achive
  end

  def render_mission_result
    puts "Best App => Achive : #{calc_achivement} " \
    " antipathy : #{@gained_antipathy} " \
    " research : #{@gained_research} "
    puts "-#{@name} was " + decide_result
  end

  def decide_result
    border_triumph = @result.border_triumph
    border_triumph -= 1 if @hero.skilled?("intercept")
    result = "fail"
    result = "success" if calc_achivement >= @result.border_success
    if @result.b_just_triumph
      result = "triumph" if calc_achivement == border_triumph
    else
      result = "triumph" if calc_achivement >= border_triumph
    end
    result
  end
end

class Approach
  attr_accessor :achievement, :name, :antipathy, :stamina, :research,
                :b_use_weapon, :b_twice_effect, :if_same_dice

  def set_def
    @name = "" if @name.nil?
    @achievement = "" if @achievement.nil?
    @antipathy = "" if @antipathy.nil?
    @stamina = "" if @stamina.nil?
    @research = "" if @research.nil?
    @if_same_dice = "" if @if_same_dice.nil?
    @b_use_weapon = false if @b_use_weapon.nil?
    @b_twice_effect = false if @b_twice_effect.nil?
  end
end

class Result
  attr_reader :reward_triumph, :reward_success, :reward_fail,
              :border_triumph, :border_success, :b_just_triumph

  def reduct_final_battle_border
    @border_success -= 8
  end
end
