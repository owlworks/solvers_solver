class Helper
  def self.roll_die(num)
    die_list = []
    (num).times do
      die_list << rand(6) + 1
    end
    die_list
  end

  def self.parse_dice_signage(str, dice)
    val_parsed = 0
    if str.to_s.start_with?("d")
      val_parsed = dice * str.slice(1, 2).to_i
    else
      val_parsed = str.to_i
    end
    val_parsed
  end

  def self.gene_perms(num_apps, list_die)
    num_die = list_die.length
    ar_num_approaches = []
    num_apps.times { |i| ar_num_approaches[i] = i }

    if ar_num_approaches.length > num_die
      (num_apps - num_die).times do
        list_die.push("n")
      end
    end
    [ar_num_approaches, list_die]
  end

  def self.enumerate_approarch_to_find(list_die, num_apps, num_useless_dice)
    num_no_dice = num_apps - list_die.count + num_useless_dice
    group_perms_die = list_die.combination(list_die.count - num_useless_dice).to_a
    perms_approach = []
    group_perms_die.each do |perm_die|
      perms_approach += enumerate_perms_approach(perm_die, num_no_dice)
    end
    perms_approach
  end

  def self.create_list_of_name(list_obj)
    str = []
    (list_obj || []).each do |obj|
      str << obj.name
    end
    str
  end

  def self.enumerate_perms_approach(list_die, num_no_dice)
    ar_num_insert_points = []
    (num_no_dice + 1).times do |i|
      ar_num_insert_points << i
    end

    perms_dice_insert_point = ar_num_insert_points.product(ar_num_insert_points)

    (list_die.count - 2).times do |_i|
      perms_dice_insert_point = perms_dice_insert_point.product(ar_num_insert_points)
    end

    perms_dice_insert_point.each(&:flatten!)

    perms = perms_dice_insert_point
    cases = []
    perms.each do |perm|
      ar_case = Array.new(num_no_dice + 1, "") # ダイスを挿入する位置
      (list_die.count).times do |i|
        ar_case[perm[i]] += list_die[i].to_s
      end
      cases << ar_case
    end

    list = []
    cases.each do |c|
      list_str = []
      c.each do |str|
        (list_die.count).times do
          list_str << str.slice!(0).to_s unless str == "" || str.nil?
        end
        list_str << "n"
      end
      list_str.pop
      list << list_str
    end
    list
  end
end
