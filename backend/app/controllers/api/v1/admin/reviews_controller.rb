class Api::V1::Admin::ReviewsController < Api::V1::BaseController
  before_action :authenticate_admin!
  before_action :set_review, only: [:destroy]

  def index
    reviews = Feedback::Review.includes(:user, :product).order(created_at: :desc)

    render json: reviews.as_json(
      include: {
        user: { only: [:id, :email] },
        product: { only: [:id, :name] }
      },
      only: [:id, :rating, :comment, :created_at]
    )
  end

  def destroy
    @review.destroy!
    render json: { message: 'Review deleted successfully.' }
  end

  private

  def set_review
    @review = Feedback::Review.find(params[:id])
  end
end
