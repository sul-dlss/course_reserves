class CurrentUser
  attr_reader :sunetid, :privgroups

  def initialize(sunetid, privgroups = [])
    @sunetid = (sunetid || '').sub('@stanford.edu', '')
    @privgroups = privgroups
  end

  def to_s
    sunetid
  end

  def superuser?
    privgroups.include?(Settings.workgroups.superuser)
  end
end
