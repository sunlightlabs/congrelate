module Monkey
  def self.backend=(backend)
    Backend.setup! backend
    backend
  end

  def self.backend
    Backend.backend
  end

  def self.invisible(*from)
    yield
  rescue Exception => error
    unless show_invisibles?
      from << caller.first[/^[^:]*/] if from.empty?
      from << __FILE__
      delete_from_backtrace(error) { |l| from.any? { |f| l.include? f } }
    end
    raise error
  end

  def self.show_invisibles?
    !!@show_invisibles
  end

  def self.show_invisibles!(show = true)
    return @show_invisibles = show unless block_given?
    # actually, that is not thread-safe. but that's no issue, as
    # it is quite unlikely and does not cause any harm.
    show_invisibles_was, @show_invisibles = @show_invisibles, show
    result = yield
    @show_invisibles = show_invisibles_was
    result
  end

  def self.hide_invisibles!(&block)
    show_invisibles!(false, &block)
  end

  def self.delete_from_backtrace(error, &block)
    if error.respond_to? :awesome_backtrace
      # HACK: we rely on the internal data structure, btw
      locations = error.instance_variable_get :@locations
      return unless locations
      locations.reject! { |l| yield l.position }
      error.instance_variable_set :@backtrace, nil
    else
      error.backtrace.reject!(&block)
    end
  end

  Dir[File.dirname(__FILE__) + "/monkey/*.rb"].sort.each do |path|
    filename = File.basename(path, '.rb')
    require "monkey/#{filename}"
  end
end