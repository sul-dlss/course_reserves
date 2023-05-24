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
      courses = CourseWorkCourses.new.all_courses
    else
      courses = CourseWorkCourses.new.find_by_sunet(current_user.sunetid)
    end
    courses.each do |course|
      cl = course.cross_listings.blank? ? "" : "(#{course.cross_listings})"
      items << [course.cid, "<a href='/reserves/new?comp_key=#{course.comp_key.gsub('&', '%26')}'>#{course.title}</a> #{cl}",
                course.instructor_names.join(", ")]
    end
    render json: { "aaData" => items }.to_json, layout: false
  end

  def show
    @reserve = Reserve.find(params[:id])
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
        if params[:sw] == 'false'
          @item = {}
        elsif params[:sw] == 'true'
          item = SearchWorksItem.new(params[:url])
          render(js: "alert('This does not appear to be a valid item in SearchWorks'); clean_up_loading();") && return unless item.valid?

          @item = item.to_h.with_indifferent_access
        end
      end
    end
  end

  def edit; end

  # Raising our own CanCan::AccessDenied here because we also let courses be created by the SUNet IDs in the course XML
  def create
    @reserve.save!

    send_course_reserve_request(@reserve) if params.key?(:send_request)
    redirect_to edit_reserve_path(@reserve[:id])
  end

  def update
    reserve = @reserve
    original_term = reserve.term
    if reserve_params[:term] != reserve.term && Reserve.where(compound_key: reserve.compound_key,
                                                              term: reserve_params[:term]).where.not(id: reserve.id).any?
      flash[:error] = "Course reserve list already exists for this course and term. The term has not been saved." # rubocop:disable Rails/I18nLocaleTexts
      reserve_params[:term] = original_term
    end
    reserve_params[:item_list] = [] unless reserve_params.key?(:item_list)
    reserve.update(reserve_params)
    send_course_reserve_request(@reserve) if params.key?(:send_request)

    redirect_to(controller: 'reserves', action: 'edit', id: params[:id])
  end

  def terms
    render layout: false if request.xhr?
  end

  def clone
    if Reserve.where(compound_key: @reserve.compound_key, term: params[:term]).any?
      flash[:error] = "Course reserve list already exists for this course and term." # rubocop:disable Rails/I18nLocaleTexts
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

  protected

  def course_for_compound_key(cid)
    CourseWorkCourses.new.find_by_compound_key(cid).first
  end

  def reserve_mail_address(reserve)
    if Settings.email.hardcoded_email_address
      Settings.email.hardcoded_email_address
    else
      "#{Settings.email_mapping[reserve.library]}, #{Settings.email.allforms}"
    end
  end

  def send_course_reserve_request(reserve)
    ReserveMailer.submit_request(reserve, reserve_mail_address(reserve), current_user).deliver_now.tap do
      reserve.update(reserve_params.merge(has_been_sent: true, sent_item_list: reserve_params[:item_list],
                                          sent_date: DateTime.now.strftime("%m-%d-%Y %I:%M%p").gsub("AM", "am").gsub("PM", "pm")))
    end
  end

  def reserve_params
    @reserve_params ||= begin
      reserve = params.require(:reserve).permit!
      reserve['item_list'] = reserve['item_list'].values if reserve['item_list']
      reserve
    end
  end

  def redirect_to_edit_when_reserve_exists
    reserve = Reserve.where(compound_key: params[:comp_key]).order("updated_at DESC").first
    return true if reserve.blank?

    redirect_to edit_reserve_path(reserve[:id])
  end
end
