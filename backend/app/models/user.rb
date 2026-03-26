class User < ApplicationRecord
  default_scope { where(deleted_at: nil) }
  scope :active, -> { where(deleted_at: nil) }

  has_secure_password
  validates :role, presence: true
  validates :email , uniqueness: true , presence: true
  validates :password_digest , presence: true
  before_validation :set_defaults
  before_validation :normalize_email

  enum :role, { customer: 0, admin: 1, seller: 2 }
  enum :seller_status, { pending: 0, approved: 1, suspended: 2 }

  has_one :cart,
          class_name: "Shopping::Cart",
          foreign_key: :user_id,
          dependent: :destroy

  has_many :orders,
           foreign_key: :user_id,
           class_name: "Checkout::Order"

  has_many :reviews,
           foreign_key: :user_id,
           class_name: "Feedback::Review",
           dependent: :destroy

  has_many :addresses,
           foreign_key: :user_id,
           dependent: :destroy

  has_many :phone_numbers,
           foreign_key: :user_id,
           dependent: :destroy

  has_many :products_for_sale,
           class_name: "Catalog::Product",
           foreign_key: :seller_id,
           dependent: :nullify

  def anonymize!()
    transaction do
        orders.update_all(user_id: nil)
      update!(
        email: "deleted_#{id}@anon.local",
        deleted_at: Time.current,
      )
      addresses.destroy_all
      phone_numbers.destroy_all
    end
  end

  def normalize_email()
    self.email = email.downcase.strip if email.present?
  end

  def seller_approved?
    seller? && approved?
  end

  def can_manage_store?
    admin? || seller_approved?
  end

  def can_shop?
    customer? && active?
  end

  private

  def set_defaults()
    self.role ||= :customer
    self.active = true if active.nil? && !seller?
    self.seller_status ||= seller? ? :pending : :approved
  end


end
