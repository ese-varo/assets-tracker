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
