class Status
  def initialize(val)
    @val = val
  end

  def set(key, val)
    old_val = @val[key]
    @val[key] = val
    old_val != val
  end

  def on!
    set(:on, true)
  end

  def off!
    set(:on, false)
  end

  def <<(val)
    @val.merge(val)
  end

  def method_missing(m, *args, &block)
    if m.to_s.end_with?('=')
      @val[m.to_s.gsub('=', '').to_sym] = args.first
    else
      @val[m]
    end
  end
end
