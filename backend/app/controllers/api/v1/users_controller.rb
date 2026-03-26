module Api
  module V1
    class UsersController < BaseController

      # Registration should be public
      skip_before_action :authenticate_user!, only: [:create]

      # ---------------------------------
      # GET /users
      # Admin only
      # ---------------------------------
      def index
        # render json: {message: "in profile"}

        return forbidden unless admin?

        render json: User.all
      end

      # ---------------------------------
      # GET /users/:id
      # Admin only
      # ---------------------------------
      def show

        # return forbidden unless admin?

        user = User.find_by(id: params[:id])
        return not_found unless user

        render json: user
      end

      # ---------------------------------
      # GET /users/me
      # Current user profile
      # ---------------------------------
      def profile
        render json: current_user
      end

      def update_password
        @user = current_user

        unless @user.authenticate(params[:current_password])
          return render json: { error: "Current password is incorrect" }, status: :unprocessable_entity
        end

        if @user.update(password: params[:password],
                        password_confirmation: params[:password_confirmation])
          render json: { message: "Password updated successfully" }
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # ---------------------------------
      # POST /users
      # Registration
      # ---------------------------------

      def create
        user = User.new(user_params)

        # Optional: force default role
        user.role ||= "customer"

        if user.save
          token = JsonWebToken.encode(user_id: user.id)

          render json: {
            message: "User created successfully",
            token: token,
          }, status: :created
        else
          render json: { errors: user.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      # ---------------------------------
      # PATCH /users/me
      # Update current user
      # ---------------------------------
      def update
        # puts "in update"
        if current_user.update(user_params)
          render json: current_user
        else
          render json: { errors: current_user.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      # ---------------------------------
      # DELETE /users/me
      # ---------------------------------
      def destroy
        if current_user.anonymize!
          head :no_content
        else
          render json: { errors: current_user.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      # Only admin can change role
      def user_params
        permitted = [:email, :password, :password_confirmation]
        permitted << :role if admin?

        params.require(:user).permit(permitted)
      end

      def admin?
        current_user&.role == "admin"
      end

      def forbidden
        render json: { error: "Forbidden" }, status: :forbidden
      end

      def not_found
        render json: { error: "User not found" }, status: :not_found
      end
    end
  end
end
