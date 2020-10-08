class Api::V1::Accounts::CodesController < Api::V1::Accounts::BaseController
  before_action :current_account
  before_action :fetch_code, except: [:index, :create]
  before_action :check_authorization

  def index
    @codes = policy_scope(Current.account.codes)
  end

  def show; end

  def create
    @code = Current.account.codes.create!(permitted_params)
  end

  def update
    @code.update!(permitted_params)
  end

  def destroy
    @code.destroy
    head :ok
  end

  private

  def fetch_code
    @code = Current.account.codes.find(params[:id])
  end

  def check_authorization
    authorize(Code)
  end

  def permitted_params
    params.require(:code).permit(:title, :description)
  end
end
