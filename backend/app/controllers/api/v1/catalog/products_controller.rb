module Api
  module V1
    module Catalog
      class ProductsController < ::Api::V1::BaseController
        before_action :set_product, only: [:show, :update, :destroy]
        before_action :authenticate_admin!, only: [:create, :update, :destroy]

        def index
          base_scope = ::Catalog::Product
            .where(active: true)
            .includes(:seller, :sub_category)

          if params[:category_id]
            sub_category_ids = ::Catalog::SubCategory
              .where(catalog_categories_id: params[:category_id])
              .select(:id)
            base_scope = base_scope.where(catalog_sub_categories_id: sub_category_ids)
          elsif params[:sub_category_id]
            base_scope = base_scope.where(catalog_sub_categories_id: params[:sub_category_id])
          end

          sub_category_counts = base_scope.group(:catalog_sub_categories_id).count

          @products = base_scope
          if params[:sub_category_ids].present?
            selected_sub_category_ids = params[:sub_category_ids].to_s.split(",")
            @products = @products.where(catalog_sub_categories_id: selected_sub_category_ids)
          end

          total_count = @products.count

          page = [params[:page].to_i, 1].max
          per_page = params[:per_page].to_i
          per_page = 8 if per_page < 1

          total_pages = [(total_count.to_f / per_page).ceil, 1].max

          @products = @products.order(:id).limit(per_page).offset((page - 1) * per_page)

          render json: {
            products: @products.as_json(
              include: {
                seller: { only: [:id, :email] },
                sub_category: { only: [:id, :name] }
              }
            ),
            meta: {
              total_count: total_count,
              total_pages: total_pages,
              current_page: page,
              sub_category_counts: sub_category_counts
            }
          }
        end

        def show
          render json: @product.as_json(
            include: {
              seller: { only: [:id, :email] },
              sub_category: { only: [:id, :name] }
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
