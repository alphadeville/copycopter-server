class Locale < ActiveRecord::Base
  belongs_to :project
  has_many :localizations, :dependent => :destroy

  validates_presence_of :key, :project_id
  validates_uniqueness_of :key, :scope => :project_id

  after_create :prevent_not_permitted_locale

  def self.enabled_in_order
    enabled.order 'key ASC'
  end

  def self.first_enabled
    order(:created_at).enabled.first
  end

  def self.locale_permitted? locale
    Locale.languages_permitted.include? locale.key
  end

  def self.languages_permitted
    Copycopter::Application.config.languages_permitted
  end

  def self.locales_permitted
    locales = []
    Locale.languages_permitted.each do |lang|
      if locale = Locale.find_by_key(lang)
        locales << locale.id
      end
    end
    locales
  end

  private

    def self.enabled
      where :enabled => true
    end

    def prevent_not_permitted_locale
      unless Locale.locale_permitted? self
        self.destroy
      end
    end

end
