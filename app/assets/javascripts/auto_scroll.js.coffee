jQuery ->
  if User.current().data_object.staff == true
    scroll(0,$(".row.osu-purple").offset().top)