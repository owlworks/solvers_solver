class ScoreCalc

  VALUE_LOSE = -5_000_000
  LIMIT_EXP = 100
  LIMIT_STATUS = 28

  def self.load_pack(param_values_pack)
    @@values = param_values_pack
  end

  def self.summary_value(company)
    value = company_value(company) + heros_value(company)
    value
  end

  def self.company_value(company)
    value = 0
    value = VALUE_LOSE if company.honor < company.antipathy
    value += company.honor * @@values["honor"]
    value += company.research * @@values["research"]
    value -= company.antipathy * @@values["antipathy"]
    value -= company.outlay * @@values["outlay"]
    value -= 100_0 unless company.b_reducting_final_mission
    num_buildings = 0
    company.list_buildings.each_with_index do |building, num_room|
      if building.nil?
        break
      else
        list_need_nexted = %w(medic armo training_room convesation_class library tech_labo shelter)
        list_obsoleting = %w(medic armo training_room convesation_class library)
        unless list_need_nexted.include?(building.name) && num_room != 1 && num_room != 3
          unless list_obsoleting.include?(building.name) && company.heros.first.level != 4
            value += @@values[building.name]
          end
        end
      end
    end
    value
  end

  def self.heros_value(company)
    value = 0
    company.heros.each do |hero|
      value += hero_value(hero)
    end
    value
  end

  def self.hero_value(hero)
    value = 0
    value += hero_params_value(hero)
    value += hero.num_actions * 100
    value += hero.stamina * 100
    (hero.list_weapons || []).each do |weapon|
      value += weapon.int_effect * @@values["weapon"]
    end
    value
  end

  def self.hero_params_value(hero)
    value = 0
    proc_add_status_value = proc do |status, value_status, limit|
      if status < limit
        value += status * value_status
      else
        value += status * limit
      end
    end
    proc_add_status_value.call(hero.exp, @@values["exp"], LIMIT_EXP)
    proc_add_status_value.call(hero.physical, @@values["physical"], LIMIT_STATUS)
    proc_add_status_value.call(hero.agility, @@values["agility"], LIMIT_STATUS)
    proc_add_status_value.call(hero.sociability, @@values["sociability"], LIMIT_STATUS)
    proc_add_status_value.call(hero.skill, @@values["skill"], LIMIT_STATUS)
    value
  end

  def self.score(name)
    @@values[name]
    return @@values[name]
  end

end
