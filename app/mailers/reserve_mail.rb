class ReserveMail < ActionMailer::Base
  default from: "no-reply@reserves.stanford.edu"
  
  def first_request(reserve)
    address = CourseReserves::Application.config.email_mapping[reserve.library]
    @reserve = reserve
    @item_text = process_new_item_list(reserve)
    mail(:to => address, :subject => "New Reserve Form: #{reserve.cid}-#{reserve.sid} - #{reserve.term}")
  end
  
  def updated_request(reserve, diff_text)
    address = CourseReserves::Application.config.email_mapping[reserve.library]
    @reserve = reserve
    @diff_text = diff_text
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
      text << "====================================\n"
    end 
    return text
  end
  
end
