class SkillTierBadge < Sequel::Model
  def self.rookie
    self.first(name: 'Rookie')
  end

  def self.recruit
    self.first(name: 'Recruit')
  end

  def self.frontiersman
    self.first(name: 'Frontiersman')
  end

  def self.squad_leader
    self.first(name: 'Squad Leader')
  end

  def self.veteran
    self.first(name: 'Veteran')
  end

  def self.commandant
    self.first(name: 'Commandant')
  end

  def self.special_ops
    self.first(name: 'Special Ops')
  end

  def self.sanji_survivor
    self.first(name: 'Sanji Survivor')
  end
end
