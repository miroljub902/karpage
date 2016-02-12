class Api::ProfilesController < ApiController
  def show
    @user = User.find_by(login: params[:id])
    respond_with @user
  end
end
