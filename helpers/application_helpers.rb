# frozen_string_literal: true

# common helpers for all controllers
module ApplicationHelpers
  def current_user
    return unless session[:user_id]

    @current_user ||= User.find_by_id(session[:user_id])
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

  def csrf_tag
    haml "%input(type='hidden' name='authenticity_token' value='#{session[:csrf]}')"
  end
end
