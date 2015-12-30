require 'pp'
require './skill.rb'

class Hero
  attr_accessor :name, :job, :level, :exp, :physical, :agility, :sociability,
                :skill, :num_room, :list_weapons, :list_items, :list_additional_approaches
  attr_reader :num_actions, :stamina, :skill_level
  EXP_THRESHOLDS = Array[10, 40, 100]
  SKILL_THRESHOLDS = Array[5, 10, 17, 28]
  STAMINA_THRESHOLD = 4
  AGILITY_THERESHOLD = 7
  NUM_MIN_ACTIONS = 2
  NUM_MIN_ACTIONS_SOLDIER = 4

  def initialize(name, job, num_room)
    @name = name
    @job = job
    @level = 1
    @exp = 0
    @num_room = num_room
    @list_weapons = []
    @sm = SkillManager.new
    @list_unique_approaches = []
    @list_additional_approaches = []
    @list_items = []
  end

  def check_new_skill(company)
    if skilled?("creative_prescription")
      skill = @sm.list_skills.find { |skill_found| skill_found.name == "creative_prescription" }
      if skill.done == false
        skill.done = true
        DirectorAI.direct_divide_bonus(self, 6)
      end
    end
    if skilled?("future_hero")
      skill = @sm.list_skills.find { |skill_found| skill_found.name == "future_hero" }
      if skill.done == false
        skill.done = true
        val = company.research.div(5) + 1
        DirectorAI.direct_divide_bonus(self, val)
      end
    end
  end

  def list_addtional_approaches
    list_approaches = []
    list_approaches << "outer_mec" if skilled?("outer_mec")
    list_approaches << "sentry_gun" if skilled?("sentry_gun")
    list_approaches << "mutant_hero" if skilled?("mutant_hero")
    list_approaches
  end

  def grow_params(perm)
    @physical += perm[0]
    @agility += perm[1]
    @sociability += perm[2]
    @skill += perm[3]
  end

  def update_params(perm)
    @physical = perm[0]
    @agility = perm[1]
    @sociability = perm[2]
    @skill = perm[3]

    # Bottom of ability by Job
    case job
    when "Soldier" then @skill = 5 if @skill < 5
    when "Police" then @agility = 4 if @agility < 4
    when "Robot" then @sociability = 5 if @sociability < 5
    when "Hustler" then @physical = 4 if @physical < 4
    end
  end

  def parse
    str_weapons = Helper.create_list_of_name(@list_weapons)
    str_skills = Helper.create_list_of_name(enumerate_skills)
    puts "+-------------------------------------------------------"
    puts "|  Name : #{@name}  Job : #{@job}  lv.#{@level}  Exp : #{@exp}"
    puts "|  Phy:#{@physical} Agi:#{@agility} Soc:#{@sociability} Skl:#{@skill}"
    puts "|  Stamina : #{stamina}  Action : #{num_actions}"
    puts "|"
    puts "|  Weapon : #{str_weapons.join(', ')}"
    puts "|  Skill : #{str_skills.join(', ')}"
    puts "|  Item : #{@list_items.join(',')}"
    puts "+-------------------------------------------------------"
  end

  def enumerate_skills
    list_skills = []
    skill_lv = skill_level
    @sm.list_skills.each do |skill|
      if skill.job == @job && skill_lv - 1 >= skill.num_in_job
        list_skills << skill
      end
    end
    list_skills
  end

  def skill_level
    skill_lv = 0
    SKILL_THRESHOLDS.each do |int_skill|
      skill_lv += 1 if int_skill <= @skill
    end
    skill_lv
  end

  def skilled?(skill_name)
    enumerate_skills.each do |skill|
      return true if skill.name == skill_name
    end
    false
  end

  def do_levelup(perm, company)
    if enable_to_levelup? == false
      puts "!! error,colundnt get next level."
      return
    end
    @physical += perm[0]
    @agility += perm[1]
    @sociability += perm[2]
    @skill += perm[3]
    @level += 1
    list_support_buildings = company.enumerate_building_connecting_barrack
    @physical += 2 if list_support_buildings.include?("medic")
    @agility += 2 if list_support_buildings.include?("training_room")
    @sociability += 3 if list_support_buildings.include?("convesation_class")
    @skill += 3 if list_support_buildings.include?("library")
    company.bm.search_by_name("labo").enable_labo_to_build if skilled?("info_network")

    check_new_skill(company)
  end

  def num_actions
    num_actions = @agility.div(AGILITY_THERESHOLD) + NUM_MIN_ACTIONS
    num_actions = 4 if skilled?("sprint") && num_actions < 4
    num_actions = 5 if skilled?("commando") && num_actions < 5
    num_actions = 5 if num_actions >= 6
    num_actions
  end

  def stamina
    stamina = 0
    stamina += @physical.div(STAMINA_THRESHOLD)
    stamina
  end

  def enable_to_levelup?
    (EXP_THRESHOLDS.length).times do |i|
      return true if EXP_THRESHOLDS[i] <= @exp && @level <= i + 1
    end
    false
  end

  def buy_weapon(weapon)
    weapon.outlay = 0 if skilled?("government_issue")
    list_weapons << weapon
  end
end
