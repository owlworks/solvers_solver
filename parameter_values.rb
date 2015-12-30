class ParameterValuePack
  attr_reader :h_values
  LIST_PARAMETERS = %w(honor antipathy outlay exp research weapon physical agility sociability skill barrack armo medic training_room convesation_class library shelter lobotomy labo tech_labo garage pr_office dispensing_center watanabe_drive)
  NUM = 9

  def initialize
    @h_values = Hash.new([])
  end

  def fetch_values_from_gene(str_gene)
    @h_values = Hash.new([])
    LIST_PARAMETERS.each_with_index do |param,i|
      fixed_point  = str_gene[i * 3 + 1, 2].to_i
      exponent = str_gene[i * 3, 1].to_i
      value = fixed_point * 10 ** exponent
      @h_values.store(param,value)
    end
  end
end
