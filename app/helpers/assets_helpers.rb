# frozen_string_literal: true

# Helpers for assets controller
module AssetsHelpers
  def log_index
    logger.info(with_cid('Asset: INDEX | Assets list accessed. (200 OK)'))
  end

  def log_assigned
    msg = 'Asset: INDEX | List of assigned assets ' \
          "for User with ID #{current_user.id}" \
          "(username: #{current_user.username}) accessed. (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_requested
    msg = 'Asset: INDEX | List of requested assets ' \
          "for User with ID #{current_user.id}" \
          "(username: #{current_user.username}) accessed. (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_pending_requests
    msg = 'Asset: INDEX | List of pending requested assets accessed. (200 OK)'
    logger.info(with_cid(msg))
  end

  def log_show
    msg = "Asset: READ | Asset details for Asset with ID #{params[:id]} " \
          '| (200 OK)'
    logger.info(with_cid(msg))
  end

  def log_form(action)
    msg = "Asset: #{action.upcase} | " \
          "#{action.capitalize} asset form requested " \
          "from IP address #{request.ip} | (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_validation_error(action, errors)
    err_msg = "Asset: #{action.upcase} | Asset with ID #{params[:id]} " \
              "#{action == 'create' ? 'creation' : 'update'} " \
              "failed due to validation errors: \n"
    errors.each { |e| err_msg << "- #{e}\n" }
    err_msg << '(400 Bad Request)'
    logger.warn(with_cid(err_msg))
  end

  def log_assign(asset, requesting_user)
    msg = "Asset: UPDATE | Asset with ID #{asset.id} requested by " \
          "User with ID #{requesting_user.id} (username: #{requesting_user.username}), " \
          "successfully assigned by User with ID #{current_user.id} " \
          "(username: #{current_user.username}) | (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_assign_error(asset, error_msg, requesting_user)
    msg = "Asset: UPDATE | Failed to accept request on Asset with ID #{asset.id}, " \
          "requested by User with ID #{requesting_user.id} " \
          "(username: #{requesting_user.username}), action attempted by " \
          "User with ID #{current_user.id} (username: #{current_user.username}) " \
          "| Error: #{error_msg} | (500 Internal Server Error)"
    logger.warn(with_cid(msg))
  end

  def log_reject(asset, requesting_user)
    msg = "Asset: UPDATE | Asset with ID #{asset.id} requested by " \
          "User with ID #{requesting_user.id} (username: #{requesting_user.username}), " \
          "successfully rejected by User with ID #{current_user.id} " \
          "(username: #{current_user.username}) | (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_reject_error(asset, error_msg, requesting_user)
    msg = "Asset: UPDATE | Failed to reject request on Asset with ID #{asset.id}, " \
          "requested by User with ID #{requesting_user.id} (username: #{requesting_user.username}), " \
          "action attempted by User with ID #{current_user.id} " \
          "(username: #{current_user.username}) | Error: #{error_msg} | (500 Internal Server Error)"
    logger.warn(with_cid(msg))
  end

  def log_request(asset)
    msg = "Asset: UPDATE | Asset with ID #{asset.id} successfully requested by " \
          "User with ID #{current_user.id} (username: #{current_user.username}) | " \
          '(200 OK)'
    logger.info(with_cid(msg))
  end

  def log_request_error(asset, error_msg)
    msg = "Asset: UPDATE | Failed to request Asset with ID #{asset.id}, action attempted by " \
          "User with ID #{current_user.id} (username: #{current_user.username}) | " \
          "Error: #{error_msg} | (500 Internal Server Error)"
    logger.warn(with_cid(msg))
  end

  def log_remove_request(asset_id, requesting_user_id)
    msg = "Asset: UPDATE | Request for Asset with ID #{asset_id} requested by" \
          "User with ID #{requesting_user_id}, successfully removed by User " \
          "with ID #{current_user.id} (username: #{current_user.username}) | (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_remove_request_error(asset_id, requesting_user_id, error_msg)
    msg = "Asset: UPDATE | Failed to remove request for Asset with ID #{asset_id}, " \
          "requested by User with ID #{requesting_user_id}, action attempted by " \
          "User with ID #{current_user.id} (username: #{current_user.username}) | " \
          "Error: #{error_msg} | (500 Internal Server Error)"
    logger.warn(with_cid(msg))
  end

  def log_unassign_error(asset, error_msg, assigned_user_id)
    msg = "Asset: UPDATE | Failed to unassign Asset with ID #{asset.id} " \
          "(assigned to User with ID #{assigned_user_id}) by" \
          "User with ID #{current_user.id} (username: #{current_user.username}) | " \
          "failed | #{error_msg} (500 Internal Server Error)"
    logger.warn(with_cid(msg))
  end

  def log_unassign(asset, assigned_user_id)
    msg = "Asset: UPDATE | Asset with ID #{asset.id} assigned to" \
          "User with ID #{assigned_user_id}, successfully unassigned by " \
          "User with ID #{current_user.id} " \
          "(username: #{current_user.username}) | (200 OK)"
    logger.info(with_cid(msg))
  end

  def log_create(asset)
    msg = "Asset: CREATE | Asset with ID #{asset.id} " \
          'created successfully | (201 Created)'
    logger.info(with_cid(msg))
  end

  def log_update(asset)
    msg = "Asset: UPDATE | Asset with ID #{asset.id} " \
          'updated successfully | (200 OK)'
    logger.info(with_cid(msg))
  end

  def log_delete(asset)
    msg = "Asset: DELETE | Asset with ID #{asset.id} " \
          'deleted successfully | (204 No Content)'
    logger.info(with_cid(msg))
  end
end
