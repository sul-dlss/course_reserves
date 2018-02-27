class ReserveMail < ActionMailer::Base
  default from: Settings.email.from
  
  def first_request(reserve, address, current_user)
    @reserve = reserve
    @item_text = process_new_item_list(reserve)
    @current_user = current_user
    mail(:to => address, :subject => "New Reserve Form: #{reserve.cid}-#{reserve.sid} - #{reserve.term}")
  end
  
  def updated_request(reserve, address, diff_text, current_user)
    @reserve = reserve
    @diff_text = diff_text
    @current_user = current_user
    mail(:to => address, :subject => "Updated Reserve Form: #{reserve.cid}-#{reserve.sid} - #{reserve.term}")
  end
  
  protected
  
  def process_new_item_list(reserve)
    text = ""
    reserve.item_list.each do |item| 
      text << "Title: #{item["title"]}\n" unless item["title"].blank? 
      text << "CKey: #{item["ckey"]} : http://searchworks.stanford.edu/view/#{item["ckey"]}\n" unless item["ckey"].blank? 
      text << "Comment: #{item["comment"]}\n" unless item["comment"].blank? 
      text << "Circ rule: #{CourseReserves::Application.config.loan_periods.key(item["loan_period"])}\n" 
      text << "Copies: #{item["copies"]}\n"
      text << "Purchase this item? Yes\n" if item.has_key?("purchase") and item["purchase"] == "true" 
      text << "Is there a personal copy available? Yes\n" if item.has_key?("personal") and item["personal"] == "true" 
      text << "------------------------------------\n"
    end 
    return text
  end
  
end
