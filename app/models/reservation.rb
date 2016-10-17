class Reservation < ApplicationRecord
  include Reservation::Validations
  has_paper_trail
  acts_as_paranoid
  belongs_to :room, optional: true
  has_one :key_card
  has_one :user_banner_record, :class_name => "BannerRecord", :foreign_key => "onid", :primary_key => "user_onid"
  before_destroy :touch
  before_destroy :create_previous_item

  def self.active
    joins(:key_card)
  end

  def self.inactive
    includes(:key_card).references(:key_cards).where("key_cards.id IS NULL")
  end

  def self.ongoing
    where("start_time <= ? AND end_time >= ?", Time.current, Time.current)
  end

  def user
    @user = nil if @user && @user.onid != user_onid
    @user ||= User.new(user_onid)
  end

  def reserver
    @reserver = nil if @reserver && @reserver.onid != reserver_onid
    @reserver ||= User.new(reserver_onid)
  end

  def user=(user)
    if user.respond_to?(:onid)
      self.user_onid = user.onid
      @user = user
    else
      self.user_onid = user.to_s
      @user = nil
    end
  end

  def reserver=(user)
    if user.respond_to?(:onid)
      self.reserver_onid = user.onid
      @reserver = reserver
    else
      self.reserver_onid = user.to_s
      @reserver = nil
    end
  end

  def duration
    self.end_time - self.start_time
  end

  def expired?
    end_time < Time.current
  end

  def current_originator
    return originator if !version
    version.originator
  end

  protected

  def create_previous_item
    @previous_state = self.send(:item_before_change)
  end

  def record_destroy
    if paper_trail_switched_on? and not new_record?
      item_before_change = @previous_state
      object_attrs = object_attrs_for_paper_trail(item_before_change)
      data = {
        :item_id   => self.id,
        :item_type => self.class.base_class.name,
        :event     => paper_trail_event || 'destroy',
        :object    => self.class.paper_trail_version_class.object_col_is_json? ? object_attrs : PaperTrail.serializer.dump(object_attrs),
        :whodunnit => PaperTrail.whodunnit
      }
      self.class.paper_trail_version_class.create merge_metadata(data)
      send(self.class.versions_association_name).send :load_target
    end
  end
end
