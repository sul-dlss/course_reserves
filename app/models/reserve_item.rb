# frozen_string_literal: true

##
# Utility class for a reserve item
class ReserveItem
  include ActiveModel::Model

  attr_accessor :title, :imprint, :ckey, :media, :online, :comment, :copies, :personal, :loan_period, :required,
                :digital_type, :digital_type_description, :purchase

  def copies
    return @copies.presence.to_i if @copies.present?
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

  def media?
    ActiveModel::Type::Boolean.new.cast(media)
  end

  def personal?
    ActiveModel::Type::Boolean.new.cast(personal)
  end

  def to_email_text(previous_data = nil)
    previous_entry = ReserveItem.new(previous_data) if previous_data
    text = []

    text << [title.presence, (" [MEDIA]" if media?)].compact.join
    text << imprint if imprint.present?
    text << "Full text available online" if online?
    text << "https://searchworks.stanford.edu/view/#{ckey}" if ckey.present?
    text << ""

    text << "Print copies needed: #{copies} #{"(WAS: #{previous_entry.copies})" if previous_entry && previous_entry.copies != copies}"
    if previous_entry && previous_entry.personal? != personal?
      text << "**CHANGED** The instructor #{personal? ? 'WILL NOW' : 'WILL NO LONGER'} loan a copy to the library"
    elsif personal?
      text << "The instructor WILL loan a copy to the library"
    end
    text << ""
    text << "Loan period: #{loan_period} #{"(WAS: #{previous_entry.loan_period})" if previous_entry && previous_entry.loan_period != loan_period}"
    text << ""
    text << "Is this a required or recommended text?"
    text << "  [#{required ? 'X' : ' '}] Required"
    text << "  [#{required ? ' ' : 'X'}] Recommended"
    text << "  (WAS: #{previous_entry.required ? 'Required' : 'Recommended'})" if previous_entry && previous_entry.required != required
    text << ""
    text << "Comment: #{comment}"
    text << "(WAS: #{previous_entry.comment})" if previous_entry&.comment&.present? && previous_entry&.comment != comment


    text.join("\n    ")
  end
end
