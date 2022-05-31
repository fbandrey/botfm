class Admin::BaseController < ApplicationController
  include AuthenticatedSystem
  layout 'main'
  before_filter :login_required
  include ApplicationHelper

end
