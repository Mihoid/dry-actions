# frozen_string_literal: true

require 'jwt'

# :reek:TooManyMethods
module WebApi
  class BaseController < ApplicationController
    respond_to :json

    authorize :user, through: :current_user
    authorize :country, through: :current_country
    authorize :session, through: :current_session

    before_action :authenticate_session
    skip_before_action :verify_authenticity_token

    rescue_from JWT::ExpiredSignature, JWT::DecodeError, with: :unauthorized_entity

    protected

    def error!(message:, title: nil, status: :unprocessable_entity)
      render json: { message: message, title: title }, status: status
    end

    private

    def unauthorized_entity(*, message: 'unauthorized')
      error! message: I18n.t("api.v1.errors.#{message}"), status: :unauthorized
    end

    def forbidden_error!
      error! message: I18n.t('api.v1.errors.access_denied'), status: :forbidden
    end

    def user_subscription_error!
      error! message: I18n.t('api.v1.errors.user_subscription'), status: :locked
    end

    def current_user
      @current_user ||= current_session&.user
    end

    def current_country
      @current_country ||= determine_country(current_user)
    end

    def authenticate_session
      unauthorized_entity if current_session.blank?
    end

    def current_session
      @current_session ||= fetch_session_from_token
    end

    def fetch_session_from_token
      token = request.headers['Authorization']&.split&.last
      result = UserAuth::Authenticate::FETCH_ENTITY.call(token: token)

      case result
      in Dry::Monads::Success(nil) | Dry::Monads::Failure(JWT::DecodeError | JWT::EncodeError)
        nil
      in Dry::Monads::Success(Session => session)
        session
      else
        raise result.failure
      end
    end

    def current_profile
      current_session&.profile
    end

    def render_internal_server_error(error)
      BugReporter.error(error)

      render json: { error: { message: error.message } }, status: :internal_server_error
    end
  end
end
