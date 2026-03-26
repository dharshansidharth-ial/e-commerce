module Api
  module V1
    module Feedback
      class ReviewsController < ::Api::V1::BaseController
        before_action :set_product

        def index
          @reviews = @product.reviews.includes(:user)
          render json: @reviews.map { |r| r.as_json.merge(user_email: r.user.email) }
        end

        def create
          return forbidden("Customers only.") unless current_user&.customer?

          @review = @product.reviews.new(review_params)
          @review.user = current_user
          if @review.save
            render json: @review.as_json.merge(user_email: @review.user.email), status: :created
          else
            render json: { errors: @review.errors }, status: :unprocessable_entity
          end
        end

        private

        def set_product
          product_id = params[:product_id] || params[:review][:product_id]
          @product = ::Catalog::Product.find(product_id)
        end

        def review_params
          params.require(:review).permit(:rating, :comment)
        end
      end
    end
  end
end
