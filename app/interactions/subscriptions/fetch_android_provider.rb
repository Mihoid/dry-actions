# frozen_string_literal: true

module Subscriptions
  class FetchAndroidProvider < BaseInteractor
    option :params, reader: :private

    def call
      safe_call { perform }
    end

    private

    def perform
      ...
    end
  end
end
