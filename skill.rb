class SkillManager
  attr_reader :list_skills
  def initialize
    @list_skills = YAML.load(File.open("./skill_data.yml"))
  end
end

class Skill
  attr_reader :name, :job, :b_active_skill, :num_in_job
  attr_accessor :done

  def done
    return @done = false if @done != true
    @done
  end
end
