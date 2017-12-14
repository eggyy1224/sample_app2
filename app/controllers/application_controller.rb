class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper#introduce helper methods to all controllers
end
