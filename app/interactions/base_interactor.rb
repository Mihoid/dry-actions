# frozen_string_literal: true

require 'dry-initializer'

class BaseInteractor
  include Dry::Monads[:maybe, :result, :try, :do]
  extend Dry::Initializer
  Dry::Validation.load_extensions(:monads)

  def self.call(*args)
    new(*args).call
  end

  def attributes
    self.class.dry_initializer.attributes(self)
  end

  private

  def sanitize_params(contract, params)
    sanitized_params = contract.new.call(params.to_h)
    return Success(sanitized_params) if sanitized_params.success?

    Failure(title: error_message('wrong_params'),
            message: sanitized_params.errors.messages.first.text)
  end

  def error_message(key, **attrs)
    I18n.t("Interactors.#{self.class.name.underscore.tr('/', '.')}.errors.#{key}", attrs)
  end

  def try_to_request(expected_exceptions: [RestClient::ExceptionWithResponse], retry_on: RestClient::Forbidden, &block)
    specific_try(*expected_exceptions) { Retryable.retryable(on: retry_on, &block) }
  end

  def try_to_parse_response_body(body)
    specific_try(JSON::ParserError) { JSON.parse(body) }
  end

  def specific_try(*exceptions, &block)
    raise ArgumentError, 'At least one exception type required' if exceptions.empty?

    Try.run(exceptions, block)
  end

  def safe_call(on_success: ->(s) { Success(s) }, on_error: ->(e) { Failure(e) }, &block)
    Try(&block).to_result.either(on_success, on_error)
  end
end
