module Api
  module V1
    module Catalog
      class CategoriesController < ::Api::V1::BaseController
        before_action :set_category, only: [:show, :update, :destroy]

        def index
          @categories = ::Catalog::Category.all
          render json: @categories
        end

        def show
          render json: @category
        end

        def create
          existing_category = ::Catalog::Category.find_by(
            "LOWER(name) = ?", category_params[:name].to_s.downcase
          )

          if existing_category
            render json: {
                     error: "Category already exists",
                   }, status: :unprocessable_entity
            return
          end

          @category = ::Catalog::Category.new(category_params)

          if @category.save
            render json: @category, status: :created
          else
            render json: {
                     errors: @category.errors.full_messages,
                   }, status: :unprocessable_entity
          end
        end

        def update
          if @category.update(category_params)
            render json: @category
          else
            render json: { errors: @category.errors }, status: :unprocessable_entity
          end
        end

        def destroy
          @category.destroy
          render json: { message: "Category deleted successfully" }, status: :no_content
        end

        private

        def set_category
          @category = ::Catalog::Category.find(params[:id])
        end

        def category_params
          params.require(:category).permit(:name, :description)
        end
      end
    end
  end
end
