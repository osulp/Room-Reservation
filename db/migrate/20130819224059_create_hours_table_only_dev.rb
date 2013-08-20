class CreateHoursTableOnlyDev < ActiveRecord::Migration
  def up
    unless Rails.env.production?
      execute "CREATE TABLE `hours` (
  `id` int(11) NOT NULL auto_increment,
  `open_time_1` text NOT NULL,
  `close_time_1` text NOT NULL,
  `open_time_5` text NOT NULL,
  `close_time_5` text NOT NULL,
  `open_time_6` text NOT NULL,
  `close_time_6` text NOT NULL,
  `open_time_7` text NOT NULL,
  `close_time_7` text NOT NULL,
  `int_open_time_1` text NOT NULL,
  `int_close_time_1` text NOT NULL,
  `int_open_time_6` text NOT NULL,
  `int_close_time_6` text NOT NULL,
  `int_open_time_7` text NOT NULL,
  `int_close_time_7` text NOT NULL,
  `published` text NOT NULL,
  `loc` text NOT NULL,
  `int_term_start_date` text NOT NULL,
  `term` text NOT NULL,
  `term_start_date` datetime NOT NULL,
  `term_end_date` datetime NOT NULL,
  `int_term_end_date` text NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `term_dates_idx` (`term_start_date`,`term_end_date`)
) ENGINE=MyISAM AUTO_INCREMENT=42 DEFAULT CHARSET=latin1 AUTO_INCREMENT=42 ;"
    end
  end

  def down
    unless Rails.env.production?
      drop_table :hours
    end
  end
end
