class Api::ReportsController < ApiController
  before_action :require_user, :find_reportable

  def create
    @report = Report.create report_params.merge(user: current_user, reportable: @reportable)
    respond_with @report, location: nil
  end

  private

  def report_params
    params.require(:report).permit(:reason, :extra_data)
  end

  def find_reportable
    klass = params[:reportable_type].constantize
    param_key = {
      'user' => 'profile_id'
    }[klass.model_name.param_key] || "#{klass.model_name.param_key}_id"
    @reportable = klass.find params[param_key]
  end
end
