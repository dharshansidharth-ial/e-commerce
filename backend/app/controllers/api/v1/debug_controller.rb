class Api::V1::DebugController < Api::V1::BaseController
    def me
        render json: {
            current_user_id: current_user&.id,
            email: current_user&.email
        }

    end
end
