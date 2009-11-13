# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :redirect_old_urls

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def render_not_found message='Page not found.'
    render :text => message, :status => :not_found
  end

  def is_ukcompanies_request?
    request.host == 'ukcompani.es' ||
        (RAILS_ENV == 'development' && request.host == 'localhost') ||
        (RAILS_ENV == 'test' && request.host == 'test.host')
  end

  def is_companiesrevealed_request?
    request.host == 'companiesrevealed.org'
  end

  def is_companiesopen_request?
    request.host == 'companiesopen.org'
  end

  def redirect_old_urls
    path = request.path
    if is_companiesrevealed_request?
      redirect_to "http://companiesopen.org#{path}", :status=>:moved_permanently
    elsif is_ukcompanies_request?
      if path.starts_with?('/search') || path == '/'
        redirect_to "http://companiesopen.org#{path}", :status=>:moved_permanently
      elsif
        redirect_to "http://companiesopen.org/uk#{path}", :status=>:moved_permanently
      end
    elsif !is_companiesopen_request?
      render(:text => 'not found', :status => 404)
    end
  end
end
