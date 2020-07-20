class ReserveMail < ActionMailer::Base
  default from: Settings.email.from

  def first_request(reserve, address, current_user)
    @reserve = reserve
    @item_text = process_new_item_list(reserve)
    @current_user = current_user
    mail(to: address, subject: "New Reserve Form: #{reserve.cid}-#{reserve.sid} - #{reserve.term}")
  end

  def updated_request(reserve, address, diff_text, current_user)
    @reserve = reserve
    @diff_text = diff_text
    @current_user = current_user
    mail(to: address, subject: "Updated Reserve Form: #{reserve.cid}-#{reserve.sid} - #{reserve.term}")
  end

  protected

  def process_new_item_list(reserve)
    text = ""
    reserve.item_list.each do |item|
      text << "Title: #{item['title']}\n" if item["title"].present?
      text << "CKey: #{item['ckey']} : https://searchworks.stanford.edu/view/#{item['ckey']}\n" if item["ckey"].present?
      text << "Imprint: #{item['imprint']}\n" if item['imprint'].present?
      text << "Comment: #{item['comment']}\n" if item["comment"].present?
      text << "Full text available online\n" if item["online"]
      text << "Digital item required:  #{I18n.t(item["digital_type"])}\n" if item["digital_type"].present?
      text << "Scan: #{item["digital_type_description"]}\n" if item["digital_type_description"].present? && item["digital_type"] == "partial_work"
      text << "------------------------------------\n"
    end
    return text
  end
end
