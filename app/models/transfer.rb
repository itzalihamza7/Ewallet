class Transfer < Transaction
  validates :from_id, presence: true, numericality: true
  validates :to_id, presence: true, numericality: true
  validate :validate_sender_receiver

  def create
    ActiveRecord::Base.transaction do
      save!
      update_balance_sender
      update_balance_receiver
    rescue StandardError => e
      errors.add(:base, e.message) if errors.empty?
      raise ActiveRecord::Rollback
    end
  end

  def update_balance_sender
    @user = from
    @user.update! balance: @user.balance - amount.to_i
  end

  def update_balance_receiver
    @user = User.find to_id
    @user.update! balance: @user.balance + amount.to_i
  end

  def validate_sender_receiver
    errors.add(:from_id, 'Cannot transfer to self') if from.id == to_id
  end
end
