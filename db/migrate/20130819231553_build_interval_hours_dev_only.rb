class BuildIntervalHoursDevOnly < ActiveRecord::Migration
  def up
    unless Rails.env.production?
        execute "CREATE TABLE `int_hours` (
      `id` int(11) NOT NULL auto_increment,
      `hours_id` int(11) NOT NULL,
      `start_date` datetime NOT NULL,
      `end_date` datetime NOT NULL,
      `open_time_wk` time NOT NULL,
      `open_time_sat` time NOT NULL,
      `open_time_sun` time NOT NULL,
      `close_time_wk` time NOT NULL,
      `close_time_sat` time NOT NULL,
      `close_time_sun` time NOT NULL,
      PRIMARY KEY  (`id`),
      KEY `dates_idx` (`start_date`,`end_date`)
    ) ENGINE=MyISAM AUTO_INCREMENT=32 DEFAULT CHARSET=latin1 AUTO_INCREMENT=32 ;"
      end
  end

  def down
    unless Rails.env.production?
      drop_table :int_hours
    end
  end
end
