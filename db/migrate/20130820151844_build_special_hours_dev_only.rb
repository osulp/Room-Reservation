class BuildSpecialHoursDevOnly < ActiveRecord::Migration
  def up
    unless Rails.env.production?
      execute "CREATE TABLE `special_hours` (
  `id` int(11) NOT NULL auto_increment,
  `hours_id` int(11) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `open_time` time NOT NULL,
  `close_time` time NOT NULL,
  `title` varchar(250) default NULL,
  PRIMARY KEY  (`id`),
  KEY `dates_idx` (`start_date`,`end_date`)
) ENGINE=MyISAM AUTO_INCREMENT=457 DEFAULT CHARSET=latin1 AUTO_INCREMENT=457 ;"
    end
  end

  def down
    unless Rails.env.production?
      drop_table :special_hours
    end
  end
end
