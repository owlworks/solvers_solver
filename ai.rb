require './company.rb'
require './score_calculator.rb'
require './investment_searcher.rb'
require 'benchmark'

class DirectorAI
  def self.direct_divide_bonus(hero, val)
    best_perm = InvestmentSearcher.divide_bonus_params(val)
    hero.grow_params(best_perm)
  end

  def self.solve_mission(company, mission)
    if mission.name == "final_battle"
      mission.result.reduct_final_battle_border if company.b_reducting_final_mission
    end
    dispatched_hero = company.heros.first
    list_die = Helper.roll_die(dispatched_hero.num_actions)
    p list_die

    best_apps = InvestmentSearcher.approaches(mission, company, list_die)
    max_achive = best_apps[2]
    weapons_use = best_apps[1]
    perm_die = best_apps[0]
    if dispatched_hero.skilled?("sentry_gun") && dispatched_hero.list_weapons != []
      sentry_weapon = ""
      list_weapons = dispatched_hero.list_weapons
      sentry_weapon = list_weapons.max do |a, b|
        a.int_effect <=> b.int_effect
      end
      mission.gain_achive_by_skill_app("sentry_gun", sentry_weapon)
      puts "--Approach[Sentry Gun] with #{sentry_weapon.name}"
    end

    if dispatched_hero.skilled?("outer_mec") && dispatched_hero.stamina >= 2
      mission.gain_achive_by_skill_app("outer_mec")
      puts "--Approach[Outer MEC]"
    end

    if dispatched_hero.skilled?("mutant_hero") && dispatched_hero.stamina >= 2
      mission.gain_achive_by_skill_app("mutant_hero")
      puts "--Approach[Mutant Hero]"
    end

    process_list_approaches(mission, perm_die, weapons_use)

    mission.render_mission_result
    mission.hero = dispatched_hero
    company.confirm_mission(mission)
    return max_achive
  end

  def self.process_list_approaches(mission, perm_die, weapons_use)
    perm_die.each_with_index do |dice, i|
      next if dice == "n"
      mission.take_approach(mission.list_approaches[i], dice.to_i, weapons_use[i])
      str_weapon = ""
      str_weapon = "(With #{weapons_use[i].name})" unless weapons_use[i] == []
      puts "--Approach[#{mission.list_approaches[i].name}] " \
      "with a dice of [#{dice}]. #{str_weapon}"
    end
  end

  def self.direct_investment(company)
    best = InvestmentSearcher.investment(company)
    perm = best[1]
    pp best
    company.extend_level += 1 if perm[0] == true
    company.add_building(perm[1]) unless perm[1] == ""
    company.heros.first.buy_weapon(perm[2]) unless perm[2] == ""
    company.heros.each do |hero|
      DirectorAI.direct_levelup(hero, company) if hero.enable_to_levelup?
    end
    company.heros.first.check_new_skill(company)
  end

  def self.direct_levelup(hero, company)
    puts "-Hero grew up by his experiences."
    pp ls = Helper.roll_die(4)
    max_score = -50_000
    ls_perm_die = ls.permutation(ls.length).to_a
    best_perm = []
    ls_perm_die.each do |perm|
      clone_hero = Marshal.load(Marshal.dump(hero))
      clone_hero.do_levelup(perm, company)
      if max_score < ScoreCalc.hero_value(clone_hero)
        max_score = ScoreCalc.hero_value(clone_hero)
        best_perm = perm
      end
    end
    hero.do_levelup(best_perm, company)
  end

  def self.direct_setup(hero)
    ls = Helper.roll_die(4)
    pp ls
    best_perm = InvestmentSearcher.levelup(hero, ls)
    hero.update_params(best_perm)
    puts("-- #{@name} joined our company.")
    hero.parse
  end
end
