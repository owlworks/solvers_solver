require './hero.rb'
require './company.rb'
require './skill.rb'
require './building.rb'
require './ai.rb'
require 'benchmark'
require './ga.rb'
require 'yaml'

list_result = []
NUM_GENES = 100
SIZE_TOUR = 4
NUM_LOOP = 50
ga = GeneticAlgorithm.new
open("result_f.yml","w") do |e|
  YAML.dump(h_result, e)
end
NUM_LOOP.times do |i|
  ar_new_codes = []
  (NUM_GENES/2).times do
    ar_codes_selected = ga.select_by_tournament(h_result,SIZE_TOUR)
    new_codes = ga.two_point_crossover(ar_codes_selected[0],ar_codes_selected[1])
    ar_new_codes << new_codes[0]
    ar_new_codes << new_codes[1]
  end

  ga.mutation_genes!(ar_new_codes,50,3)
  h_result = ga.eval_gene(ar_new_codes)
  pp h_result
  open("result#{i}.yml","w") do |e|
    YAML.dump(h_result, e)
  end
end


