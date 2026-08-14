class Api::V1::Seller::DashboardController < Api::V1::BaseController
  before_action :authenticate_seller!

  def show
    products = current_user.products_for_sale
      .includes(:reviews, sub_category: :catalog_category)
      .order(created_at: :desc)
    reviews = Feedback::Review
      .joins(:product)
      .where(catalog_products: { seller_id: current_user.id })
      .includes(:user, :product)
      .order(created_at: :desc)

    revenue = products.sum { |product| product.revenue.to_f }

    render json: {
      seller: {
        id: current_user.id,
        email: current_user.email,
        seller_status: current_user.seller_status,
      },
      metrics: {
        revenue: revenue,
        products_count: products.size,
        active_products_count: products.count(&:active),
        reviews_count: reviews.size,
      },
      products: products.map do |product|
        {
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          stock: product.stock,
          active: product.active,
          image_url: product.image_url,
          sub_category: product.sub_category&.as_json(
            only: [:id, :name],
            include: { catalog_category: { only: [:id, :name] } }
          ),
          revenue: product.revenue.to_f,
          reviews_count: product.reviews.size,
        }
      end,
      reviews: reviews.map do |review|
        review.as_json(
          include: {
            user: { only: [:id, :email] },
            product: { only: [:id, :name] }
          },
          only: [:id, :rating, :comment, :created_at]
        )
      end
    }
  end
end
