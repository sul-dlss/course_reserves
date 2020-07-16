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
      text << "Imprint: #{item['imprint']}\n" if item['imprint'].present?
      text << "CKey: #{item['ckey']} : http://searchworks.stanford.edu/view/#{item['ckey']}\n" if item["ckey"].present?
      text << "Comment: #{item['comment']}\n" if item["comment"].present?
      text << "Circ rule: #{Settings.loan_periods.to_h.key(item['loan_period'])}\n"
      text << "Copies: #{item['copies']}\n"
      text << "Purchase this item? Yes\n" if item.key?("purchase") && (item["purchase"] == "true")
      text << "Is there a personal copy available? Yes\n" if item.key?("personal") && (item["personal"] == "true")
      text << "------------------------------------\n"
    end
    return text
  end
end
