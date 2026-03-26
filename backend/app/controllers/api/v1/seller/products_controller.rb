class Api::V1::Seller::ProductsController < Api::V1::BaseController
  before_action :authenticate_seller!
  before_action :set_product, only: [:show, :update, :destroy]

  def index
    products = current_user.products_for_sale.includes(:category, :reviews).order(created_at: :desc)
    render json: products.map { |product| serialize_product(product) }
  end

  def show
    render json: serialize_product(@product)
  end

  def create
    product = current_user.products_for_sale.new(product_params)

    if product.save
      render json: serialize_product(product), status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: serialize_product(@product)
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.order_items.exists?
      @product.update!(active: false)
      render json: { message: "Product archived because it is part of existing orders.", product: serialize_product(@product) }
    else
      @product.destroy!
      render json: { message: "Product deleted successfully." }
    end
  end

  private

  def set_product
    @product = current_user.products_for_sale.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :active, :catalog_category_id, :image_url)
  end

  def serialize_product(product)
    product.as_json(
      include: {
        category: { only: [:id, :name] },
        reviews: {
          include: {
            user: { only: [:id, :email] }
          },
          only: [:id, :rating, :comment, :created_at]
        }
      }
    ).merge(
      revenue: product.revenue.to_f,
      reviews_count: product.reviews.size
    )
  end
end
