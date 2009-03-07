class CompaniesController < ApplicationController

  before_filter :ensure_current_url, :only => :show

  def search
    @query  =  params[:q]
    @companies = Company.find_all_by_company_name(@query)

    redirect_to :controller=>"companies", :action=>"show", :id => @companies.last.friendly_id if @companies.size == 1
  end

  def show
  end

  private

    def ensure_current_url
      begin
        unless params[:id].include? '+'
          @company = Company.find_this(params[:id])
          redirect_to @company, :status => :moved_permanently if @company.has_better_id?
        end
      rescue
        render_not_found
      end
    end
end
