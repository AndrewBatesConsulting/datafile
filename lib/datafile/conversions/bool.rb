class String
  def to_bool
    b = false
    if self =~ /^true$/i
      b = true
    elsif self =~ /^false$/i
      b = false
    elsif self =~ /^1$/
      b = true
    elsif self =~ /^0$/
      false
    end
    return b
  end
end
