class BuildBannerLookupDevOnly < ActiveRecord::Migration
  def up
    unless Rails.env.production?
      execute "CREATE TABLE `BannerLookup` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `onid` varchar(9) NOT NULL,
  `status` varchar(30) NOT NULL,
  `email` varchar(128) NOT NULL,
  `fullName` varchar(41) NOT NULL,
  `idHash` char(128) NOT NULL,
  PRIMARY KEY  (`ID`),
  KEY `idHash` (`idHash`),
  KEY `onid` (`onid`)
) ENGINE=MyISAM AUTO_INCREMENT=307742 DEFAULT CHARSET=latin1 AUTO_INCREMENT=307742 ;"
    end
  end

  def down
    unless Rails.env.production?
      drop_table "BannerLookup"
    end
  end
end
