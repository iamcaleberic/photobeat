class User < ActiveRecord::Base
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100#" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  attr_accessor :login

  acts_as_messageable
  # has_many :photos #has many becomes plural
  belongs_to :role
  has_many :photos, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  def admin?
    self.role.name == 'admin'
  end

  def contributor?
    self.role.name == 'contributor'
  end

  def mua?
    self.role.name == 'contributor'
  end

  def model?
    self.role.name == 'model'
  end

  def photographer?
    self.role.name == 'photographer'
  end

  #Authentication


  # Only allow letter, number, underscore and punctuation.
  validate :validate_username

  #show username instead id in url.
  def to_param
    username
  end

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end

  def mailboxer_name
    self.name
  end

  def mailboxer_email(object)
    self.email
  end
end
