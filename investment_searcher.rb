require './ai.rb'
require './approach_searcher.rb'
class InvestmentSearcher
  def self.levelup(hero, list_die)
    max_score = -50_000
    ls_perm_die = list_die.permutation(list_die.length).to_a
    best_perm = []
    ls_perm_die.each do |perm|
      clone_hero = Marshal.load(Marshal.dump(hero))
      clone_hero.update_params(perm)
      if max_score < ScoreCalc.hero_value(clone_hero)
        max_score = ScoreCalc.hero_value(clone_hero)
        best_perm = perm
      end
    end
    best_perm
  end

  def self.divide_bonus_params(val)
    best_perm = [0, 0, 0, 0]
    ar_weight_params = [[0, ScoreCalc.score("physical")], [1, ScoreCalc.score("agility")], [2, ScoreCalc.score("sociability")], [3, ScoreCalc.score("skill")]]
    ar_weight_params.sort_by! { |params| params[1] }
    best_perm[ar_weight_params[3][0]] = val
    best_perm
  end

  def self.trial_to_extend(company, max_score, best_perm)
    if company.enable_to_extend?
      clone_company = Marshal.load(Marshal.dump(company))
      clone_company.extend_level += 1
      result = trial_to_add_building(clone_company, max_score, best_perm)
      if result[0] > max_score
        max_score = result[0]
        best_perm[0] = true
      end
    end
    result = trial_to_add_building(company, max_score, best_perm)
    if result[0] > max_score
      max_score = result[0]
      best_perm[0] = false
    end
    [max_score, best_perm]
  end

  def self.trial_to_add_building(company, max_score, best_perm)
    available_buildings = company.bm.enumerate_available(company)
    available_buildings << ""
    if company.enable_to_build?
      available_buildings.each do |building|
        next if building != "" && building.outlay + company.outlay > company.honor
        clone_company = Marshal.load(Marshal.dump(company))
        clone_company.add_building(building) if building != ""
        result = trial_to_buy_weapon(clone_company, max_score, best_perm)
        if result[0] > max_score
          max_score = result[0]
          best_perm[1] = building
        end
      end
    end
    [max_score, best_perm]
  end

  def self.trial_to_buy_weapon(company, max_score, best_perm)
    available_weapons = company.wm.enumerate_available(company, company.heros.first)
    available_weapons << ""
    (available_weapons || []).each do |weapon|
      next if weapon != "" && weapon.outlay + company.outlay > company.honor
      clone_company = Marshal.load(Marshal.dump(company))
      clone_company.heros.first.buy_weapon(weapon) if weapon != ""
      result = ScoreCalc.summary_value(clone_company)
      if result > max_score
        max_score = result
        best_perm[2] = weapon
      end
    end
    [max_score, best_perm]
  end

  def self.investment(company)
    max_score = -500_000_000
    best_perm = ["", "", ""]
    trial_to_extend(company, max_score, best_perm)
  end

  def self.approaches(mission, company, list_die)
    as = ApproachSearcher.new(company, mission, list_die)
    as.search_best_apps
  end
end
