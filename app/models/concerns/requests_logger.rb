module RequestsLogger
  extend ActiveSupport::Concern

  module ClassMethods
    def log_key(sufix='')
      "#{name}_log_storage#{sufix}"
    end

    def log_storage
      @log_storage ||= Redis::List.new(log_key, marshal: true)
    end

    def log_rotation_storage
      @log_rotation_storage ||= Redis::List.new(log_key('rotation'), marshal: true)
    end

    def rotate_requests_logs(&block)
      Redis::Semaphore.new(log_key 'semaphore').lock do
        values = log_rotation_storage.to_a

        if values.blank? && log_storage.any?
          Redis.current.rename log_key, log_key('rotation')
          values = log_rotation_storage.to_a
        end

        yield(values) if block_given? && values.any?
        clean_requests_logs
      end
    end

    def clean_requests_logs
      log_storage.clear
      log_rotation_storage.clear
    end

    def log_request(*data)
      log_storage << [nil, *data]
      true
    end
  end

  def log_request(*data)
    log_storage << [id, *data]
    true
  end

  delegate :log_key, :log_storage, :log_rotation_storage, :rotate_requests_logs, :clean_requests_logs,
    to: :class
end