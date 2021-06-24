# frozen_string_literal: true

##
# Utility class for a reserve item
class ReserveItem
  include ActiveModel::Model

  attr_accessor :title, :imprint, :ckey, :media, :online, :comment, :digital_type, :copies, :personal, :loan_period, :required

  def copies
    return @copies.presence if @copies.present?
    return 0 if online?

    1
  end

  def online?
    ActiveModel::Type::Boolean.new.cast(online)
  end

  def required
    return true if @required.blank?

    ActiveModel::Type::Boolean.new.cast(@required)
  end
end
