class Api::V1::PhoneNumbersController < Api::V1::BaseController
    before_action :set_user

    def index
        @phone_numbers = @user.phone_numbers.all
        render json: @phone_numbers
    end

    def show 
        @phone_number = @user.phone_numbers.find_by(id: params[:id])
        if @phone_number
            render json: @phone_number
        else
            not_found()
        end

    end

    def create
        @phone_number = @user.phone_numbers.new(phone_number_params)

        if @phone_number.save()
            render json: @phone_number
        else
            show_errors()
        end
        
    end

    def update
        @phone_number = @user.phone_numbers.find_by(id: params[:id])
        
        if @phone_number
            if @phone_number.update(phone_number_params)
                render json: {message: "Update Success!"}
            else
                show_errors()
            end
        else
            not_found()
        end
    end

    def destroy
        @phone_number = @user.phone_numbers.find_by(id: params[:id])
        if @phone_number
            @phone_number.destroy()
            render json: {message: "Deletion success!"}
        else
            not_found()
        end
    end

    private
    def set_user()
        @user = current_user
    end

    def phone_number_params()
        params.permit(:phone_number , :verified)

    end

    def not_found()
        render json: {error: "Phone number not found!"}
    end

    def show_errors
        render json: {error: @phone_number.errors.full_messages}
    end

end
