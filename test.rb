require './hero.rb'
require './company.rb'
require './skill.rb'
require './building.rb'
require './ai.rb'
require 'benchmark'
require './ga.rb'
require 'yaml'

    NUM_TRY = 1000
    test_code = "257023134056131310237433191917320559121121080642079312426327069095088377"
    ar_lost_mission = [0,0,0,0,0,0,0,0,0,0,0,0]
    ar_max_final_achive = []

    pvp = ParameterValuePack.new
    pvp.fetch_values_from_gene(test_code)
    pp pvp

    ScoreCalc.load_pack(pvp.h_values)
    NUM_TRY.times do
      company = Company.new("Scientist")
      DirectorAI.direct_setup(company.heros.first)
      (company.mm.list_missions.length).times do |num_mission|
        company.mm.list_missions[num_mission].hero = company.heros.first
        max = DirectorAI.solve_mission(company, company.mm.list_missions[num_mission])
        DirectorAI.direct_investment(company)
        company.heros.first.parse
        company.parse
        if num_mission == company.mm.list_missions.length - 1
          ar_max_final_achive << max
        end
        if company.gameover?
          puts "***GameOver"
          ar_lost_mission[num_mission] += 1
          break
        end
      end
      ar_lost_mission[11] += 1 unless company.gameover?
    end
    pp ar_lost_mission
    pp ar_max_final_achive
