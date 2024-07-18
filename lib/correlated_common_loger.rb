# frozen_string_literal: true

# Custom logger for requests. It adds a correlation_id field to the log
# to identify logs that belongs to the same request
class CorrelatedCommonLogger < Rack::CommonLogger
  def log(env, status, header, began_at)
    now = Time.now.strftime('%d/%b/%Y:%H:%M:%S %z')
    duration = Rack::Utils.clock_time - began_at
    length = extract_content_length(header)

    logger = @logger || env['rack.errors']
    logger <<
      "\"correlation_id: #{env['correlation_id']}\" " \
      "#{env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR'] || '-'} -" \
      "#{env['REMOTE_USER'] || '-'} [#{now}] " \
      "\"#{env['REQUEST_METHOD']} #{env['PATH_INFO']}" \
      "#{env['QUERY_STRING'].empty? ? '' : "?#{env['QUERY_STRING']}"} " \
      "#{env['HTTP_VERSION']}\" #{status} #{length} " \
      "\"#{env['HTTP_REFERER'] || '-'}\" " \
      "\"#{env['HTTP_USER_AGENT'] || '-'}\" #{duration.round(4)}\n"
  end
end
