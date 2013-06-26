class ApplicationController < ActionController::API
	include ActionController::MimeResponds
	include ActionController::StrongParameters

	respond_to :json
end
