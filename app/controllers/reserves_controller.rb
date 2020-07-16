require 'net/http'
require 'nokogiri'
require 'terms'
class ReservesController < ApplicationController
  load_and_authorize_resource except: :new
  skip_authorize_resource only: :index
  skip_load_resource only: :index

  before_action :redirect_to_edit_when_reserve_exists, only: :new

  def index
    @reserves = if current_user.superuser?
                  Reserve.includes(:editors).where(editors: { sunetid: current_user.sunetid })
                else
                  Reserve.accessible_by(current_ability)
                end
  end

  def all_courses
    render layout: false if request.xhr?
  end

  def all_courses_response
    items = []
    if current_user.superuser?
      courses = CourseWorkCourses.instance.all_courses
    else
      courses = CourseWorkCourses.instance.find_by_sunet(current_user.sunetid)
    end
    courses.each do |course|
      cl = course.cross_listings.blank? ? "" : "(#{course.cross_listings})"
      items << [course.cid, "<a href='/reserves/new?comp_key=#{course.comp_key.gsub('&', '%26')}'>#{course.title}</a> #{cl}", course.instructor_names.join(", ")]
    end
    render json: { "aaData" => items }.to_json, layout: false
  end

  def new
    @course = course_for_compound_key(params[:comp_key])
    @reserve = Reserve.new(compound_key: params[:comp_key])
    raise RecordNotFound if @course.blank?

    authorize! :create, @reserve
  end

  def add_item
    respond_to do |format|
      format.js do
        params[:index] = 0
        if params[:sw] == 'false'
          params[:item] = {}
        elsif params[:sw] == 'true'
          ckey = params[:url].strip[/(\d+)$/]
          item = SearchWorksItem.new(ckey)
          render(js: "alert('This does not appear to be a valid item in SearchWorks'); clean_up_loading();") && return unless item.valid?
          params[:item] = item.to_h
        end
      end
    end
  end

  # Raising our own CanCan::AccessDenied here because we also let courses be created by the SUNet IDs in the course XML
  def create
    @reserve.save!

    send_course_reserve_request(@reserve) if params.key?(:send_request)
    redirect_to edit_reserve_path(@reserve[:id])
  end

  def edit; end

  def update
    reserve = @reserve
    original_term = reserve.term
    if reserve_params[:term] != reserve.term
      if Reserve.where(compound_key: reserve.compound_key, term: reserve_params[:term]).where.not(id: reserve.id).any?
        flash[:error] = "Course reserve list already exists for this course and term. The term has not been saved."
        reserve_params[:term] = original_term
      end
    end
    reserve_params[:item_list] = [] unless reserve_params.key?(:item_list)
    if params.key?(:send_request) && (reserve.has_been_sent == true)
      send_updated_reserve_request(reserve)
    elsif params.key?(:send_request) && ((reserve.has_been_sent == false) || reserve.has_been_sent.nil?)
      send_course_reserve_request(reserve)
    else
      reserve.update_attributes(reserve_params)
    end
    redirect_to(controller: 'reserves', action: 'edit', id: params[:id])
  end

  def terms
    render layout: false if request.xhr?
  end

  def clone
    if Reserve.where(compound_key: @reserve.compound_key, term: params[:term]).any?
      flash[:error] = "Course reserve list already exists for this course and term."
      redirect_to(edit_reserve_path(@reserve)) && return
    end
    reserve = @reserve.dup
    reserve.has_been_sent = nil
    reserve.disabled = nil
    reserve.sent_date = nil
    reserve.term = params[:term]
    reserve.save!
    redirect_to(edit_reserve_path(reserve[:id]))
  end

  def show
    @reserve = Reserve.find(params[:id])
  end

  protected

  def course_for_compound_key(cid)
    CourseWorkCourses.instance.find_by_compound_key(cid).first
  end

  def reserve_mail_address reserve
    if Settings.email.hardcoded_email_address
      Settings.email.hardcoded_email_address
    else
      "#{Settings.email_mapping[reserve.library]}, #{Settings.email.allforms}"
    end
  end

  def send_course_reserve_request(reserve)
    reserve.update_attributes(reserve_params.merge(has_been_sent: true, sent_item_list: reserve_params[:item_list], sent_date: DateTime.now.strftime("%m-%d-%Y %I:%M%p").gsub("AM", "am").gsub("PM", "pm")))

    ReserveMail.first_request(reserve, reserve_mail_address(reserve), current_user).deliver_now
  end

  def send_updated_reserve_request(reserve)
    old_reserve = reserve.dup
    reserve.update_attributes(reserve_params.merge(has_been_sent: true, sent_item_list: reserve_params[:item_list], sent_date: DateTime.now.strftime("%m-%d-%Y %I:%M%p").gsub("AM", "am").gsub("PM", "pm")))
    diff_text = process_diff(old_reserve.sent_item_list, reserve.item_list)

    ReserveMail.updated_request(reserve, reserve_mail_address(reserve), diff_text, current_user).deliver_now
  end

  def process_diff(old_reserve, new_reserve)
    total_reserves = []
    item_text = ""
    new_reserve.each_with_index do |new_item, index|
      total_reserves << new_item
      unless old_reserve.include?(new_item)
        old_item = old_reserve.map { |item| item if (item["ckey"].blank? && (item["comment"] == new_item["comment"])) || (item["ckey"].present? && (item["ckey"] == new_item["ckey"])) }.compact.first
        if old_item.present?
          total_reserves << old_item
          item_text << "***EDITED ITEM***\n"
          new_item.each do |key, value|
            if old_item[key] == value
              item_text << "#{translate_key_for_email(key)}#{translate_value_for_email(key, value)}\n" unless value.blank? && old_item[key].blank?
            else
              item_text << "#{translate_key_for_email(key)}#{translate_value_for_email(key, value)} (was: #{translate_value_for_email(key, old_item[key])})\n"
            end
          end
          item_text << "------------------------------------\n"
        else
          item_text << "***ADDED ITEM***\n"
          new_item.each do |key, value|
            item_text << "#{translate_key_for_email(key)}#{translate_value_for_email(key, value)}\n" if value.present?
          end
          item_text << "------------------------------------\n"
        end
      end
    end
    (old_reserve - total_reserves).each do |delete_item|
      item_text << "***DELETED ITEM***\n"
      delete_item.each do |key, value|
        item_text << "#{translate_key_for_email(key)}#{translate_value_for_email(key, value)}\n" if value.present?
      end
      item_text << "------------------------------------\n"
    end
    item_text
  end

  def translate_key_for_email(key)
    return translations[key.to_s]
  end

  def translations
    { "title" => "Title: ",
      "ckey" => "CKey: ",
      "comment" => "Comment: ",
      "loan_period" => "Circ rule: ",
      "copies" => "Copies: ",
      "purchase" => "Purchase this item? ",
      "personal" => "Is there a personal copy available? " }
  end

  def translate_value_for_email(key, value)
    if value == "true"
      return "yes"
    elsif key.to_s == "loan_period"
      return Settings.loan_periods.to_h.key(value)
    elsif key.to_s == "ckey"
      return "#{value} : #{searchworks_ckey_url(value)}"
    elsif value.blank?
      return "blank"
    else
      return value
    end
  end

  def searchworks_ckey_url ckey
    "https://searchworks.stanford.edu/view/#{ckey}"
  end

  def reserve_params
    params.require(:reserve).permit!
  end

  def redirect_to_edit_when_reserve_exists
    reserve = Reserve.where(compound_key: params[:comp_key]).order("updated_at DESC").first
    return true if reserve.blank?

    redirect_to edit_reserve_path(reserve[:id])
  end
end
