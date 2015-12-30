require './parameter_values.rb'
require 'pp'

class Gene
  attr_accessor :code
  NUM_PARAMS = ParameterValuePack::LIST_PARAMETERS.length
  NUM_TRY = 10

  def initialize(code = gene_rnd)
    @code = code
  end

  def gene_rnd
    gene = ""
    NUM_PARAMS.times do |_num|
      prms = rand(399)
      gene += format('%03d', prms)
    end
    gene
  end

  def evaluation
    ar_lost_mission = []
    ar_max_final_achive = []
    one_clear_achive = 51
    no_clear_achive = 59
    num_point_clear = 1

    pvp = ParameterValuePack.new
    pvp.fetch_values_from_gene(@code)
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
          if max >= one_clear_achive
            num_point_clear += 1
          end
          if max >= no_clear_achive
            num_point_clear += 1
          end
        end
        if company.gameover?
          puts "***GameOver"
          ar_lost_mission << num_mission+1
          break
        end
      end
      ar_lost_mission << 12 unless company.gameover?
    end

    value = 0
    ar_lost_mission.each do |num_mission|
      case num_mission
      when 7..11
        value += 1
      end
    end

    total = 0
    ar_max_final_achive.each{|i| total += i}
    unless total == 0
      avg_final_achive = total / ar_max_final_achive.size
    else
      avg_final_achive = 0
    end
    p value
    value += avg_final_achive
    value *= num_point_clear
    pp ar_lost_mission
    p "avg_max_achive : #{avg_final_achive}"
    return value

  end

  def parse_to_binary
    binary = @code.to_i.to_s(2)
    p binary
  end
end

class GeneticAlgorithm
  SIZE_TOURNAMENT = 3

  def first_genes(num_genes)
    h_result = Hash.new{}
     num_genes.times do |i|
      ng = Gene.new
      h_result.store(ng.code,ng.evaluation)
    end
    return h_result
  end

  def eval_gene(ar_codes)
    h_result = Hash.new{}
     ar_codes.each do |code|
      ng = Gene.new(code)
      h_result.store(ng.code,ng.evaluation)
    end
    return h_result
  end

  def select_by_tournament(h_genes,num_tournament=SIZE_TOURNAMENT)
    selected_code_a = pick_winner_tournament(h_genes,num_tournament)
    selected_code_b = pick_winner_tournament(h_genes,num_tournament)
    return selected_code_a,selected_code_b
  end

  def two_point_crossover(code_a,code_b)
    ar_rnd_pos = []
    length_code = code_a.length
    ar_rnd_pos << rand(length_code)
    ar_rnd_pos << rand(length_code)
    ar_rnd_pos.sort!
    pp ar_rnd_pos
    new_code_a = code_a.slice(0..ar_rnd_pos[0]) + code_b.slice(ar_rnd_pos[0]+1..ar_rnd_pos[1]) + code_a.slice(ar_rnd_pos[1]+1..length_code)
    new_code_b = code_b.slice(0..ar_rnd_pos[0]) + code_a.slice(ar_rnd_pos[0]+1..ar_rnd_pos[1]) + code_b.slice(ar_rnd_pos[1]+1..length_code)
    return new_code_a,new_code_b
  end

  def pick_winner_tournament(h_genes,size_tournament)
    tournament = []
    SIZE_TOURNAMENT.times do
      tournament << h_genes.to_a.sample
    end
    selected_code = tournament.max_by {|code,val| val }[0]
    return selected_code
  end

  def mutation_genes!(ar_codes,num_odds,num_mutation)
    ar_codes.each do |code|
      next if rand(100)+1 < num_odds
      num_mutation.times do
        point = rand(code.length-1)
        case point.modulo(3)
        when 0
          code[point] = (rand(3) + 1).to_s
        else
          code[point] = (rand(9) + 1).to_s
        end
      end
    end
  end

end


