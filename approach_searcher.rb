class ApproachSearcher
  def initialize(company, mission, list_die)
    mission.hero = company.heros.first
    @company = company
    @mission = mission
    @clone_hero = Marshal.load(Marshal.dump(company.heros.first))
    @list_die = list_die
    @num_apps = mission.list_approaches.count
    @max_score = -5_000_000
    @max_perm = []
    @max_weapons = []
    @num_useless_dice = 0
    @max_achive = 0
    @sentry_weapon = ""
  end

  def search_best_apps
    # CodingStyleGuide博士、お許しください
    flag_update_max = true
    while flag_update_max == true
      flag_update_max = false
      pp @list_die

      @ar_permutation = Helper.enumerate_approarch_to_find(@list_die, @num_apps, @num_useless_dice)
      p "---- Testing #{@ar_permutation.count} cases."
      @ar_permutation.each do |perm|
        clone_company = Marshal.load(Marshal.dump(@company))
        clone_mission = Marshal.load(Marshal.dump(@mission))
        weapons = []
        stamina = @clone_hero.stamina
        b_mutant_heros = false
        b_outer_mec = false
        @sentry_weapon = ""

        # 追加アプローチ
        if @clone_hero.skilled?("sentry_gun") && @clone_hero.list_weapons != []
          list_weapons = @clone_hero.list_weapons
          @sentry_gun = list_weapons.max do |a, b|
            a.int_effect <=> b.int_effect
          end
        end

        if @clone_hero.skilled?("outer_mec") && stamina >= 2
          b_outer_mec = true
          stamina -= 2
        end

        if @clone_hero.skilled?("mutant_hero") && stamina >= 2
          b_mutant_heros = true
          stamina -= 2
        end

        for i in 0..perm.length - 1 do
          app_search = clone_mission.list_approaches[i]
          consume_stamina = clone_mission.calc_consume_stamina(app_search, app_search.stamina, perm[i])
          perm[i] = "n" unless check_consume_stamina?(perm[i], @mission, app_search, stamina)
          perm[i] = "n" unless check_same_dice_approach?(perm, app_search, i)
          weapon_to_use = select_weapon_use(app_search, @clone_hero, weapons)
          weapons[i] = []; next if perm[i] == "n"

          clone_mission.take_approach(app_search, perm[i], weapon_to_use)
          stamina -= consume_stamina
          weapons[i] = weapon_to_use
        end

        if @sentry_weapon != ""
          clone_mission.gain_achive_by_skill_app("sentry_gun", @sentry_weapon)
        end
        clone_mission.gain_achive_by_skill_app("outer_mec") if b_outer_mec
        clone_mission.gain_achive_by_skill_app("mutant_hero") if b_mutant_heros

        clone_company.confirm_mission(clone_mission)
        @max_achive = check_max_achive?(@max_achive, clone_mission)

        if @max_score < ScoreCalc.summary_value(clone_company)
          @max_score = ScoreCalc.summary_value(clone_company)
          @max_perm = perm
          @max_weapons = weapons
          flag_update_max = true
        end
        @num_useless_dice += 1
      end
    end
    [@max_perm, @max_weapons,@max_achive]
  end

  private

  def check_max_achive?(max_achive, mission)
    if max_achive < mission.calc_achivement
      max_achive = mission.calc_achivement
      puts "Found max_achive:#{max_achive}" \
        "  antipathy:#{mission.gained_antipathy}" \
        "  research:#{mission.gained_research} "
    end
    max_achive
  end

  def check_consume_stamina?(perm_target, mission, app, stamina)
    consume_stamina = mission.calc_consume_stamina(app, app.stamina, perm_target)
    return false if stamina < consume_stamina
    true
  end

  def select_weapon_use(app_search, hero, weapons)
    weapon_to_use = []
    return weapon_to_use unless app_search.b_use_weapon
    list_weapons = hero.list_weapons
    list_weapons << @sentry_weapon unless @sentry_weapon == ""
    (weapons || []).each do |weapon_used|
      next if weapon_used == []
      (list_weapons || []).delete_if do |ls_w|
        ls_w.name == weapon_used.name
      end
    end
    unless list_weapons == []
      weapon_to_use = list_weapons.max do |a, b|
        a.int_effect <=> b.int_effect
      end
    end
    weapon_to_use
  end

  def check_same_dice_approach?(perm_die, app_search, target_index)
    str_same = app_search.if_same_dice
    ar_same = []
    if str_same != ""
      if str_same.is_a?(Integer)
        ar_same[0] = str_same.to_i
      else
        ar_same = str_same.split("-")
      end
      ar_same.each do |same_dice|
        return false unless perm_die[same_dice.to_i] == perm_die[target_index]
      end
    end
    true
  end
end
