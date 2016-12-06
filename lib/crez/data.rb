CourseReserves::Application.config.reserve_libraries = {
  "ART-RESV" => "Art & Architecture Library (Bowes)",
  "BUS-RESV" => "Business Library",
  "EARTH-RESV" => "Earth Sciences Library (Branner)",
  "EAS-RESV" => "East Asia Library",
  "EDU-RESV" => "Education Library (Cubberley)",
  "ENG-RESV" => "Engineering Library (Terman)",
  "GREEN-RESV" => "Green Library",
  "HOP-RESV" => "Marine Biology Library (Miller)",
  "LAW-RESV" => "Law Library (Crown)",
  "MEDIA-RESV" => "Media & Microtext Center",
  "MUSIC-RESV" => "Music Library"
  "SCI-RESV" => "Science Library (Li and Ma)"
}
CourseReserves::Application.config.email_mapping = {
  "ART-RESV" => "artlibrary@stanford.edu",
  "BUS-RESV" => "gsb_library-i-desk@stanford.edu",
  "EARTH-RESV" => "brannerlibrary@stanford.edu",
  "EAS-RESV" => "eastasialibrary@stanford.edu",
  "EDU-RESV" => "cubberley@stanford.edu",
  "ENG-RESV" => "englibrary@stanford.edu",
  "GREEN-RESV" => "greenreserves@stanford.edu",
  "HOP-RESV" => "hms-library@mailman.stanford.edu",
  "LAW-RESV" => "crowncirc@lists.stanford.edu",
  "MEDIA-RESV" => "mediamicro@stanford.edu",
  "MUSIC-RESV" => "muslibcirc@stanford.edu"
}
CourseReserves::Application.config.loan_periods = {
  "2HWF-RES"   => "2 hours",
  "3HWF-RES"   => "3 hours",
  "4HWF-RES"   => "4 hours",
  "1DNDWF-RES" => "1 day",
  "2DWF-RES"   => "2 days",
  "3DWF-RES"   => "3 days"
}
CourseReserves::Application.config.terms = [
  {:term => "Winter 2012", :quarter => "Winter", :end_date => Date.new(2012, 3, 23)},
  {:term => "Spring 2012", :quarter => "Spring", :end_date => Date.new(2012, 6, 13)},
  {:term => "Summer 2012", :quarter => "Summer", :end_date => Date.new(2012, 8, 18)},
  {:term => "Fall 2012",   :quarter => "Fall",   :end_date => Date.new(2012, 12, 14)},

  {:term => "Winter 2013", :quarter => "Winter", :end_date => Date.new(2013, 3, 22)},
  {:term => "Spring 2013", :quarter => "Spring", :end_date => Date.new(2013, 6, 12)},
  {:term => "Summer 2013", :quarter => "Summer", :end_date => Date.new(2013, 8, 17)},
  {:term => "Fall 2013",   :quarter => "Fall",   :end_date => Date.new(2013, 12, 13)},

  {:term => "Winter 2014", :quarter => "Winter", :end_date => Date.new(2014, 3, 21)},
  {:term => "Spring 2014", :quarter => "Spring", :end_date => Date.new(2014, 6, 11)},
  {:term => "Summer 2014", :quarter => "Summer", :end_date => Date.new(2014, 8, 16)},
  {:term => "Fall 2014",   :quarter => "Fall",   :end_date => Date.new(2014, 12, 12)},

  {:term => "Winter 2015", :quarter => "Winter", :end_date => Date.new(2015, 3, 20)},
  {:term => "Spring 2015", :quarter => "Spring", :end_date => Date.new(2015, 6, 10)},
  {:term => "Summer 2015", :quarter => "Summer", :end_date => Date.new(2015, 8, 15)},
  {:term => "Fall 2015",   :quarter => "Fall",   :end_date => Date.new(2015, 12, 11)},

  {:term => "Winter 2016", :quarter => "Winter", :end_date => Date.new(2016, 3, 18)},
  {:term => "Spring 2016", :quarter => "Spring", :end_date => Date.new(2016, 6, 8)},
  {:term => "Summer 2016", :quarter => "Summer", :end_date => Date.new(2016, 8, 13)},
  {:term => "Fall 2016",   :quarter => "Fall",   :end_date => Date.new(2016, 12, 16)},

  {:term => "Winter 2017", :quarter => "Winter", :end_date => Date.new(2017, 3, 24)},
  {:term => "Spring 2017", :quarter => "Spring", :end_date => Date.new(2017, 6, 14)},
  {:term => "Summer 2017", :quarter => "Summer", :end_date => Date.new(2017, 8, 19)},
  {:term => "Fall 2017",   :quarter => "Fall",   :end_date => Date.new(2017, 12, 15)},

  {:term => "Winter 2018", :quarter => "Winter", :end_date => Date.new(2018, 3, 23)},
  {:term => "Spring 2018", :quarter => "Spring", :end_date => Date.new(2018, 6, 13)},
  {:term => "Summer 2018", :quarter => "Summer", :end_date => Date.new(2018, 8, 18)},
  {:term => "Fall 2018",   :quarter => "Fall",   :end_date => Date.new(2018, 12, 14)},

  {:term => "Winter 2019", :quarter => "Winter", :end_date => Date.new(2019, 3, 22)},
  {:term => "Spring 2019", :quarter => "Spring", :end_date => Date.new(2019, 6, 12)},
  {:term => "Summer 2019", :quarter => "Summer", :end_date => Date.new(2019, 8, 17)},
  {:term => "Fall 2019",   :quarter => "Fall",   :end_date => Date.new(2019, 12, 13)},

  {:term => "Winter 2020", :quarter => "Winter", :end_date => Date.new(2020, 3, 20)},
  {:term => "Spring 2020", :quarter => "Spring", :end_date => Date.new(2020, 6, 10)},
  {:term => "Summer 2020", :quarter => "Summer", :end_date => Date.new(2020, 8, 15)}
]
