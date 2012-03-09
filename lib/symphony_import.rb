module SymphonyImport
  
  # Another test to show item_list from active db
  def show_item_list(cid, sid, term)
    #course_result = CourseReserves::Application.config.courses.find_by_class_id_and_section(cid, sid)
    course_result = Reserve.find_by_cid_and_sid_and_term(cid, sid, term)
    
    if ! course_result.nil?
      puts course_result.inspect
    else
      puts "could not find result for #{cid} - #{sid} - #{term}"
    end
    
  end
  
  # Take a file of cids and get back the sunet IDs for them
  def check_cids(file_path)
    
    # get file of course_ids
    entries = File.readlines(file_path)
    entries.map {|x| x.chomp! }
    
    not_found = []
    found = []
    
    # Go through each line, split on "|", search the XML, and print the number of entries in the array and the first SID
    entries.each do |cid|    
      #puts "cid and sunet is: #{cid} - #{sunet}"
      course_from_xml = CourseReserves::Application.config.courses.find_by_class_id(cid)
      # puts course_from_xml.inspect
      if course_from_xml.blank?
        ins_ids = 'course not found'
        not_found << cid
      else
        ins_ids = ''
        course_from_xml.first[:instructors].each do |k,v|
          ins_ids << k[:sunet] + ", "
        end
        ins_ids.gsub!(/, $/, '')
        found << "#{cid}|#{ins_ids}"
      end
      #puts "sid is: " + sid
      puts "cid and sunet is: #{cid} - #{ins_ids}"
    end
    
    #Write out files
    file_dir = '/Users/jonathanlavigne/Documents/Course_Reserves/comp_keys/'
    File.open("#{file_dir}not_found.txt", 'w') do |f|  
      not_found.each do |e|
        f.puts e
      end  
    end
    File.open("#{file_dir}found.txt", 'w') do |f|  
      found.each do |e|
        f.puts e
      end  
    end
    
  end # check cids
  
  def loan_period(code)
     
    loan_periods = { "2H" => "2 hours",
                     "4H" => "4 hours",
                     "1DND-RES" => "1 day",
                     "2D-RES" => "2 days",
                     "3D-RES" => "3 days"
                   }
      trans = loan_periods[code]
      
      if trans.blank?
        trans = ""  
      end
      
      return trans         
    
  end
  
  # Just a temp test to try to match up symphony course info with XML from CW
  def test_sym_cw(file_path)
    
    # get file of course_ids and sunet IDs
    entries = File.readlines(file_path)
    entries.map {|x| x.chomp! }
    
    # Go through each line, split on "|", search the XML, and print the number of entries in the array and the first SID
    entries.each do |e|
      cid, sunet = e.split(/\|/)
      #puts "cid and sunet is: #{cid} - #{sunet}"
      course_from_xml = CourseReserves::Application.config.courses.find_by_class_id_and_sunet(cid, sunet)
      if course_from_xml.blank?
        sid = '01-set by method'
      else
        sid = course_from_xml.first[:sid]
      end
      #puts "sid is: " + sid
      puts "cid and sunet is: #{cid} - #{sunet} - #{sid}"
    end
    
  end
  
  # Take a file name, read the lines into an array and remove newlines, then
  # then call get_course_info to get array of courses and course list that we
  # use to create database records
  def process_import_file(file_path)
    
    entries = File.readlines(file_path)
    entries.map {|x| x.chomp! }    
    
    courses, course_lists = get_course_info( entries )
    
    # Add the item list to the course hash    
    courses.each do |key, value|
      courses[key] = value.merge!({:item_list => course_lists[key]}) 
    end   
    
    # Iterate over the courses hash to create records
    courses.each do |key, value|
      r = Reserve.create(value)
      r.save!
    end
    
    # return courses
    
  end # process_import_file
  
  
  # Take a line and return cid - instructor ID as key plus hash of all pipe-delimited fields
  def get_entry_hash_and_key( line )

    fields = line.split(/\|/)
    # Keys are from https://consul.stanford.edu/display/NGDE/Symphony+Course+Reserves+Data+spec but will change somewhat
    # Added :instructor_sunet_id and :item_title at end for nowpr
    keys = [:reserve_desk, :resctl_expire_date, :resctl_status, :ckey, :barcode, :home_location, 
            :current_location, :item_reserve_status, :title, :loan_period, :reserve_expire_date, :reserve_stage, 
            :course_id, :course_name, :term, :instructor_lib_id, :instructor_univ_id, :instructor_name, :instructor_sunet_id,
            :instructor_email, :instructor_phone
            ]
    fields_hash = Hash[*keys.zip(fields).flatten]
    fields_hash[:instructor_sunet_id].downcase!
    fields_hash[:loan_period] = loan_period(fields_hash[:loan_period])
    course_from_xml = CourseReserves::Application.config.courses.find_by_class_id_and_sunet(fields_hash[:course_id], fields_hash[:instructor_sunet_id])
    if course_from_xml.blank?
      fields_hash[:sid] = '01'
    else
      fields_hash[:sid] = course_from_xml.first[:sid]
      fields_hash[:comp_key] = course_from_xml.first[:comp_key]
      fields_hash[:cross_listings] = course_from_xml.first[:cross_listings]
      #puts "course from xml" + course_from_xml.first.inspect
    end
    #puts "fieldsid is " + fields_hash[:sid].inspect
    fields_hash[:term] = fields_hash[:term].capitalize + ' ' + fields_hash[:resctl_expire_date][0,4]
    entry_key = fields_hash[:course_id] + '-' + fields_hash[:instructor_sunet_id]

    return entry_key, fields_hash

  end # get_entry_hash_and_key
  
  
  # Add an entry for a course to courses hash with cid + instructor ID as key
  def add_to_courses( courses, key, fields_hash )

     courses[key] = { :cid => fields_hash[:course_id],
                      :sid => fields_hash[:sid],
                      :desc => fields_hash[:course_name],
                      :library => fields_hash[:reserve_desk],
                      #:term => fields_hash[:term],
                      :term => 'Winter 2012', # hard code this string for 3/12 load
                      :compound_key => fields_hash[:comp_key],
                      :cross_listings => fields_hash[:cross_listings],
                      :has_been_sent => "true",
                      :disabled => "true",
                      :contact_name => fields_hash[:instructor_name],
                      :contact_phone => fields_hash[:instructor_phone],
                      :contact_email => fields_hash[:instructor_email],
                      :instructor_names => fields_hash[:instructor_name],
                      :instructor_sunet_ids => fields_hash[:instructor_sunet_id]
                    }

     return courses

  end # add_to_courses
  
  # Add an item hash to a course list and return the list
  def add_to_course_lists( list, fields_hash )
    
    # :title
    # :ckey
    # :comment
    # :copies
    # :personal
    # :purchase
    # :loan_period
    if fields_hash[:home_location] == 'INSTRUCTOR'
      personal = "true"
    else
      personal = ""
    end
      

    #list <<  { :ckey => fields_hash[:ckey], :title => fields_hash[:title], :loan_period => fields_hash[:loan_period], :personal => personal }
    list <<  { "title" => fields_hash[:title], "ckey" => fields_hash[:ckey],  "comment" => "", "media" => "", "loan_period" => fields_hash[:loan_period],  :personal => personal }

    return list

  end # add_to_course_list
  
  
  # Take an array of pipe-delimited entries exported from Symphony, put data into
  # appropriate hashes keyed by course_id + instructor_id, return hashes
  # of courses and course lists
  def get_course_info( entries )

    courses = {}
    course_lists = {}
    copy_count = {}

    # Iterate over all lines and add data to courses, course_lists, and copy_count hashes
    entries.each do |line|

      key, fields_hash = get_entry_hash_and_key(line)

      # Add entry to courses hash if not there already
      if ! courses.has_key?(key)
        courses = add_to_courses( courses, key, fields_hash )
      end # add to course

      # Add new hash to lists within courses_lists hash for key
      if course_lists.has_key?(key)
        course_lists[key] = add_to_course_lists(course_lists[key], fields_hash)
      else
        list = []
        course_lists[key] = add_to_course_lists( list, fields_hash )
      end # add to course_list

      # Add to copy count for each ckey for appropriate course
      if copy_count.has_key?(key) # have entry for course
         if copy_count[key].has_key?(fields_hash[:ckey]) # have entry for ckey so add 1
           copy_count[key][fields_hash[:ckey]] = copy_count[key][fields_hash[:ckey]] + 1
         else # no entry for ckey, so add with value 1
           copy_count[key][fields_hash[:ckey]] = 1
         end
      else
         ckey = {}
         ckey[fields_hash[:ckey]] = 1
         copy_count[key] = ckey
      end # add to copy count

    end # do each line

    # Now add copy count to item list in course_lists hash
    course_lists.each do |key, value|
       val_arr_new = []
       #Keys for value hash must be strings
       value.each do |val_hash_entry|
         count = copy_count[key][val_hash_entry["ckey"]] 
         val_hash_entry["copies"] = count     
         val_arr_new << val_hash_entry
       end
       course_lists[key] = val_arr_new.uniq.sort_by { |hsh| hsh["title"] }
       #puts "course_lists[key] for #{key} after sort is " + course_lists[key].inspect
       #puts '<br>===============<br>'
    end

    return courses, course_lists

  end # create_course_hashes
  

end
  
  
  
  
  
  