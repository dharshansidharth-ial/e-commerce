class Api::V1::Admin::ProductsController < Api::V1::BaseController
  before_action :authenticate_admin!
  before_action :set_product, only: [:show, :update, :destroy]

  def index
    products = Catalog::Product.includes(:category, :seller).order(created_at: :desc)
    render json: products.as_json(
      include: {
        category: { only: [:id, :name] },
        seller: { only: [:id, :email, :seller_status] }
      }
    )
  end

  def show
    render json: @product.as_json(
      include: {
        category: { only: [:id, :name] },
        seller: { only: [:id, :email, :seller_status] }
      }
    )
  end

  def create
    product = Catalog::Product.new(product_params)

    if product.save
      render json: product.as_json(
        include: {
          category: { only: [:id, :name] },
          seller: { only: [:id, :email, :seller_status] }
        }
      ), status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: @product.as_json(
        include: {
          category: { only: [:id, :name] },
          seller: { only: [:id, :email, :seller_status] }
        }
      )
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.order_items.exists?
      @product.update!(active: false)
      render json: { message: 'Product archived because it is part of existing orders.', product: @product }
    else
      @product.destroy!
      render json: { message: 'Product deleted successfully.' }
    end
  end

  private

  def set_product
    @product = Catalog::Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :price,
      :stock,
      :active,
      :catalog_category_id,
      :image_url,
      :seller_id
    )
  end
end
