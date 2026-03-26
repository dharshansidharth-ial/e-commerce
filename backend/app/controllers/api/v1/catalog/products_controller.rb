module Api
  module V1
    module Catalog
      class ProductsController < ::Api::V1::BaseController
        before_action :set_product, only: [:show, :update, :destroy]
        before_action :authenticate_admin!, only: [:create, :update, :destroy]

        def index
          @products = ::Catalog::Product
            .where(active: true)
            .includes(:seller, :category)

          render json: @products.as_json(
            include: {
              seller: { only: [:id, :email] },
              category: { only: [:id, :name] }
            }
          )
        end

        def show
          render json: @product.as_json(
            include: {
              seller: { only: [:id, :email] },
              category: { only: [:id, :name] }
            }
          )
        end

        def create
          @product = ::Catalog::Product.new(product_params)
          if @product.save
            render json: @product, status: :created
          else
            render json: { errors: @product.errors }, status: :unprocessable_entity
          end
        end

        def update
          if @product.update(product_params)
            render json: @product
          else
            render json: { errors: @product.errors }, status: :unprocessable_entity
          end
        end

        def destroy
          @product.destroy
          render json: { message: "Product deleted successfully" }, status: :no_content
        end

        private

        def set_product
          @product = ::Catalog::Product.find(params[:id])
        end

        def product_params
          params.require(:product).permit(:name, :description, :price, :stock, :active, :catalog_category_id, :image_url, :seller_id)
        end
      end
    end
  end
end
