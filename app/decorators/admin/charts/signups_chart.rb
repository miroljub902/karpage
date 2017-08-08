class Admin::Charts::SignupsChart < Draper::Decorator
  attr_reader :labels, :data

  PERIODS = %i[today yesterday last_7 last_30 this_year last_year lifetime].freeze

  def initialize(period)
    @period = period && PERIODS.include?(period.to_sym) ? period.to_sym : :today
    __send__ "retrieve_#{@period}"
  end

  private

  def z
    @_z ||= ActiveSupport::TimeZone['Pacific Time (US & Canada)']
  end

  def retrieve_today
    @labels = ['Today']
    @data = query(from: z.now, to: z.now, span: :day)
  end

  def retrieve_yesterday
    @labels = ['Yesterday']
    @data = query(from: z.yesterday, to: z.yesterday, span: :day)
  end

  def retrieve_last_7
    range = (z.now - 8.days).to_date..z.yesterday
    @labels = range.map { |d| d.strftime '%a %-d' }
    @data = query(from: range.first, to: range.last, span: :day)
  end

  def retrieve_last_30
    range = (z.now - 30.days).to_date..z.yesterday
    @labels = range.map { |d| d.strftime '%b %-d' }
    @data = query(from: range.first, to: range.last, span: :day)
  end

  def retrieve_this_year
    range = (z.now.beginning_of_year).to_date..z.yesterday
    @labels = range.map { |d| d.strftime '%b' }.uniq
    @data = query(from: range.first, to: range.last, span: :month)
  end

  def retrieve_last_year
    start = (z.now - 1.year).beginning_of_year.to_date
    range = start..start.end_of_year
    @labels = range.map { |d| d.strftime '%b' }.uniq
    @data = query(from: range.first, to: range.last, span: :month)
  end

  def retrieve_lifetime
    start = User.order(created_at: :asc).limit(1).pluck(:created_at).first.to_date
    range = start..z.yesterday
    @labels = range.map { |d| d.strftime '%b \'%y' }.uniq
    @data = query(from: range.first, to: range.last, span: :month)
  end

  def query(from:, to:, span:)
    counts = User.where(created_at: from.in_time_zone(z).beginning_of_day..to.in_time_zone(z).end_of_day)
    case span
    when :day
      counts = counts.group_by_day(:created_at, time_zone: z)
    when :month
      counts = counts.group_by_month(:created_at, time_zone: z)
    end
    @data = counts.count.values
  end
end
