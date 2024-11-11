class JobScheduler
  SLEEP_DEFAULT_INTERVAL = 12

  def initialize
    @jobs = JobList.new
    @thread = nil
  end

  def run
    fetch_jobs
    @thread = Thread.new do
      loop do
        if @jobs.ready?
          @jobs.execute_next
        else
          sleep_time = wait_interval || SLEEP_DEFAULT_INTERVAL
          p "sleep_time #{sleep_time}"
          sleep sleep_time
        end
      end
    end
  end

  def stop
    @thread.kill if @thread
  end

  def fetch_jobs
    @jobs << BackgroundJob.new('morning', 'daily', '12:42', 2)
  end

  def wait_interval
    time_to_exec = @jobs.first.time_to_exec.to_i
    # p "#wait_interval time_to_exec = #{time_to_exec}"
    return nil if @jobs.empty?# || time_to_exec == 0
    # @jobs.empty? ? nil : @jobs.first.time_to_exec
    time_to_exec
  end

  class JobList < Array
    # NOTE: determines if there is a pending job to be run at that time
    def ready?
      return nil if self.empty?

      order_by_time_to_exec
      job = self.first
      # NOTE: give a gap of -10 to 10 sec to catch any offset from zero
      # due to processing time fluctuations
      # (job.time_to_exec.abs < 10) && (now_without_sec - job.last_execution > 10)
      # job.time_to_exec == 0 && job.last_execution < Time.now
      job.time_to_exec == 0 && (Time.now - job.last_execution > 60)
    end

    def order_by_time_to_exec
      # TODO: implement quicksort sorting
      min_by { |job| job.time_to_exec }
    end

    def execute_next
      # return if Time.now - self.first.last_execution < 60
      self.first.execute
      self.first.last_execution = now_without_sec
      # p "#execute_next, last_execution = #{self.first.last_execution.to_i} #{self.first.last_execution}"
      order_by_time_to_exec
    end
  end

  class BackgroundJob
    attr_reader :name, :frequency, :time, :priority, :created_at
    attr_accessor :last_execution
    FREQUENCY_PERIODS = %w[hourly daily weekly monthly]
    ONE_HOUR = 60 * 60
    ONE_DAY = ONE_HOUR * 24
    ONE_WEEK = ONE_DAY * 7

    def initialize(name, frequency, time = '23:00', priority = 2, last_execution = nil)
      @name = name
      @frequency = frequency
      @time = time
      @priority = priority
      @last_execution = last_execution
      @next_execution_time = nil
      @created_at = now_without_sec
      # @created_at = now_without_sec - ONE_DAY
    end

    def execute
      puts "//////////////////// Job #{name} is being executed ////////////////////"
    end

    def next_execution_time
      raise 'Not valid frequency value' unless FREQUENCY_PERIODS.include?(frequency)
      @next_execution_time ||= case frequency
                               when 'hourly' then next_hourly
                               when 'daily' then next_daily
                               when 'weekly' then nil
                               when 'monthly' then nil
                               end
    end

    def time_to_exec
      next_e = next_execution_time
      # p "time_to_exec: #{next_e.to_i} // #{next_e}\ntime now: #{now.to_i} // #{now}"
      next_e - now_without_sec
    end

    def last_execution # INFO: set to created_at on first execution
      @last_execution ? @last_execution : created_at
    end

    private
      def next_daily # INFO: execute job in the day it was created if scheduled hour hasn't passed
        if due_today?
          p "due today"
          Time.new(year, month, day, hour, minutes, 0) # NOTE: should be executed in the current day
        else # NOTE: should be executed in the next day
          p "execute next day"
          Time.new(year, month, day, hour, minutes, 0) + ONE_DAY
        end
      end

      def next_hourly
        Time.new(year, month, day, hour, 0, 0) + ONE_HOUR
      end

      def due_today?
        now = Time.now
        # p "now = #{now} // #{now.to_i}\nnow.hour = #{now.hour}\nnow.min = #{now.min}\nhour = #{hour}\nminutes = #{minutes}"
        # p "now = #{now} // minutes = #{minutes} min = #{now.min}"
        # now.hour < hour || (
        #   now.hour == hour &&
        #   now.min <= minutes &&
        #   (now - last_execution > 10)
        # )
        day != now.day
      end

      def year = last_execution.year
      def month = last_execution.month
      def day = last_execution.day
      def hour = time.split(':').first.to_i
      def minutes = time.split(':').last.to_i
  end
end

def now_without_sec
  now = Time.now
  Time.at(now.to_i - now.sec)
end

=begin

SCHEDULER MAIN LOGIC

Problem: sleep time calculation is generating negative values
This is being caused by using the last execution time as the only reference
to determine if the job has been executed 

Solution: 

=end
