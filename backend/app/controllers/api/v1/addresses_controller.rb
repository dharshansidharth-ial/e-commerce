module Api
  module V1
    class AddressesController < BaseController
      before_action :set_user

      def index
        # set_user()
        render json: @user.addresses
      end

      def show
        render json: @user.addresses.find_by(id: params[:id])
        # render json: params
      end

      def create
        @address = @user.addresses.new(address_params)
        # puts @address.inspect

        if @address.save
          render json: { message: "address added!" }, status: :created
        else
          render json: { errors: @address.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        @address = @user.addresses.find_by(id: params[:id])
        # render json: @address
        if @address
          if @address.update(address_params)
            show()
          else
            show_errors()
          end
        else
          not_found()
        end
      end

      def destroy
        @address = @user.addresses.find_by(id: params[:id])

        if @address
          if @address.destroy
            render json: { message: "Deletion Success!", address: @address }
          else
            show_errors()
          end
        else

          not_found()
        end
      end

      private

      def set_user()
        # render json: params
        @user = current_user
      end

      def address_params()
        params.require(:address).permit(:line1, :city, :country, :default)
        # permitted[:default] = false if permitted[:default].nil?

        # permitted
      end

      def not_found()
        render json: { error: "address not found!" }
      end

      def show_errors()
        render json: { error: @address.errors.full_messages }
      end
    end
  end
end
