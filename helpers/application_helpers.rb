# frozen_string_literal: true

# common helpers for all controllers
module ApplicationHelpers
  def current_user
    return unless session[:user_id]

    @current_user ||= User.find_by_id(session[:user_id])
  end

  def flash
    env['sinatra.flash']
  end

  def with_cid(text)
    "\"correlation_id: #{env['correlation_id']}\" -- : #{text}"
  end

  def logger
    settings.logger
  end

  def error_logger
    settings.error_logger
  end

  def log_generic_error(custom_msg = '')
    error = env['sinatra.error']
    error_msg = "Server: ERROR | #{error.class}: #{custom_msg || '--'} | " \
                "(500 Internal Server Error)\n" \
                "#{error.message}\n" \
                "#{error.backtrace.join('\n')}"
    error_logger.error(with_cid(error_msg))
  end

  def log_not_found
    msg = "Resource: NOT_FOUND | #{env['sinatra.error'].message} " \
          '(404 Not Found)'
    logger.info(with_cid(msg))
  end

  # return specified params with keys as symbols
  def params_slice_with_sym_keys(*keys)
    params.slice(*keys).to_h.transform_keys(&:to_sym)
  end

  def partial(template, locals = {})
    haml(:"partials/#{template}", locals: locals)
  end

  def request_path_is_public?
    public_paths.include? request.path_info
  end

  def public_paths
    raise NotImplementedError
  end

  def masked(val)
    '*' * val.length
  end

  def masked_params
    data = []
    params.each do |key, val|
      masked_value = sensitive_params.include?(key) ? masked(val) : val
      data << "#{key}: #{masked_value}"
    end
    "Data: #{data.join(', ')}"
  end

  def sensitive_params
    raise NotImplementedError
  end

  def csrf_tag
    haml "%input(type='hidden' name='authenticity_token' value='#{session[:csrf]}')"
  end
end
