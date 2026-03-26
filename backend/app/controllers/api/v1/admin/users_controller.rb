class Api::V1::Admin::UsersController < Api::V1::BaseController
  before_action :authenticate_admin!
  before_action :set_seller, only: [:update]

  def index
    sellers = User
      .where(role: :seller)
      .includes(:products_for_sale)
      .order(created_at: :desc)

    render json: sellers.map { |seller| serialize_seller(seller) }
  end

  def update
    status = params.dig(:user, :seller_status)
    return render json: { error: "Invalid seller status." }, status: :unprocessable_entity unless User.seller_statuses.key?(status)

    @seller.assign_attributes(
      seller_status: status,
      active: status == "approved"
    )

    if @seller.save
      render json: serialize_seller(@seller)
    else
      render json: { errors: @seller.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_seller
    @seller = User.find(params[:id])
    return if @seller&.seller?

    render json: { error: "Seller not found." }, status: :not_found
  end

  def serialize_seller(seller)
    {
      id: seller.id,
      email: seller.email,
      active: seller.active,
      seller_status: seller.seller_status,
      products_count: seller.products_for_sale.count,
      revenue: seller.products_for_sale.sum { |product| product.revenue.to_f },
      created_at: seller.created_at,
    }
  end
end
