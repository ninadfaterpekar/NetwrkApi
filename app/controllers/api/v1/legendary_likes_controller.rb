class Api::V1::LegendaryLikesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    if current_user.able_to_post_legendary?
      @like = LegendaryLike.where(message_id: params[:legendary][:message_id],
                                  user_id: current_user.id).first
      message = Message.find_by(id: params[:legendary][:message_id])
      if @like.present?
        render json: message
      else
        @like = LegendaryLike.new(like_params)
        if @like.save
          message.legendary_count += 1
          message.save
          current_user.update(legendary_at: DateTime.now)
          current_user.save
          UserMailer.legendary_mail(message.user_id).deliver_now
          render json: message
        else
          head 422
        end
      end
    else
      render json: {error: 'You cannot set messages as legendary so often'}, status: 422
    end
  end

  def index
    render json: {able_to_post_legendary: current_user.able_to_post_legendary?}
  end

  private

  def like_params
    params.require(:legendary).permit(:user_id,
                                      :message_id)
  end
end
