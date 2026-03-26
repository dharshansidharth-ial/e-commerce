class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:register, :login]

  def login
    @user = User.find_by(email: params[:email])

    if @user&.authenticate(params[:password]) && @user.deleted_at.nil?
      if @user.seller?
        if @user.pending?
          return render json: { error: 'Seller account pending admin approval.' }, status: :forbidden
        end

        if @user.suspended?
          return render json: { error: 'Seller account suspended by admin.' }, status: :forbidden
        end
      end

      token = JsonWebToken.encode(user_id: @user.id)

      render json: {
        login: 'success',
        token: token,
        user: {
          id: @user.id,
          email: @user.email,
          role: @user.role,
        },
      }
    else
      render json: { error: 'Invalid Credentials!' }, status: :unauthorized
    end
  end

  def register
    @user = User.new(user_params)
    @user.role = permitted_public_role(@user.role)
    @user.active = !@user.seller?
    @user.seller_status = @user.seller? ? :pending : :approved

    if @user.save
      token = JsonWebToken.encode(user_id: @user.id)

      render json: {
        message: 'Registration Success!',
        token: token,
      }, status: :created
    else
      render json: {
        errors: @user.errors.full_messages,
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end

  def permitted_public_role(role)
    %w[customer seller].include?(role) ? role : 'customer'
  end
end
