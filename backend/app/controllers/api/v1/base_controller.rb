module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!
      attr_reader :current_user

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: e.message }, status: :not_found
      end

      def authenticate_admin!
        puts current_user.inspect
        return unauthorized unless current_user&.admin?
      end

      def authenticate_seller!
        return unauthorized unless current_user&.seller_approved?
      end

      def ensure_customer!
        return forbidden("Customers only.") unless current_user&.customer?
        return forbidden("Your customer account is inactive.") unless current_user&.active?
      end

      private

      def authenticate_user!
        header = request.headers["Authorization"]
        return unauthorized unless header

        puts "fine"
        token = header.split(" ").last
        decoded = JsonWebToken.decode(token)
        return unauthorized unless decoded

        @current_user = User.find_by(id: decoded[:user_id])
        return unauthorized unless @current_user
        return unauthorized if @current_user.deleted_at.present?
      end

      def unauthorized
        puts "in unauthorized!"
        render json: { error: "Unauthorized" }, status: :unauthorized
      end

      def forbidden(message = "Forbidden")
        render json: { error: message }, status: :forbidden
      end
    end
  end
end

# def render_not_found
#   render json: { error: "Resource not found" }, status: :not_found
# end

# def show
#   resource = find_resource
#   if resource.nil?
#     render_not_found
#   else
#     render json: resource
#   end
# end
