module SymphonyImport
  
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
    entry_key = fields_hash[:course_id] + '-' + fields_hash[:instructor_sunet_id]

    return entry_key, fields_hash

  end # get_entry_hash_and_key
  
  
  # Add an entry for a course to courses hash with cid + instructor ID as key
  def add_to_courses( courses, key, fields_hash )

     courses[key] = { :cid => fields_hash[:course_id],
                      :sid => '01',
                      :desc => fields_hash[:course_name],
                      :library => fields_hash[:reserve_desk],
                      :term => fields_hash[:term],
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
      

    list <<  { :ckey => fields_hash[:ckey], :title => fields_hash[:title], :loan_period => fields_hash[:loan_period], :personal => personal }

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
       #puts "key + value here is: " + key.inspect + ' => ' + value.inspect
       val_arr_new = []
       value.each do |val_hash_entry|
         #puts "val_hash_entry is: " + val_hash_entry.inspect
         count = copy_count[key][val_hash_entry[:ckey]]
         val_hash_entry[:copies] = count
         val_arr_new << val_hash_entry
       end
       course_lists[key] = val_arr_new.uniq.sort_by { |hsh| hsh[:item_title] }
    end

    return courses, course_lists

  end # create_course_hashes
  

end
  
  
  
  
  
  