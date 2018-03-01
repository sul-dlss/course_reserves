class CurrentUser
  attr_reader :sunetid, :privgroups

  def initialize(sunetid, privgroups = '')
    @sunetid = sunetid
    @privgroups = privgroups.split('|').flatten
  end

  def to_s
    sunetid
  end

  def superuser?
    privgroups.include?(Settings.workgroups.superuser)
  end
end
