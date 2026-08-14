module Api
  module V1
    module Catalog
      class SubCategoriesController < ::Api::V1::BaseController

        def index
          @sub_categories = ::Catalog::SubCategory.where(catalog_categories_id: params[:category_id])
          render json: @sub_categories
        end

        def show
          @sub_category = ::Catalog::SubCategory.find(params[:id])
          render json: @sub_category
        end

      end
    end
  end
end



