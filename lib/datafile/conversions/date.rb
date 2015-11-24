class String
  def to_date
    if self =~ /^\d{1,2}\/\d{1,2}\/\d{4}$/
      return Time.strptime(self, "%m/%d/%Y")
    elsif self =~ /^\d{1,2}\/\d{1,2}\/\d{2}$/
      return Time.strptime(self, "%m/%d/%y")
    elsif self =~ /^\d{1,2}\/\d{1,2}\/\d{4} \d{2}:\d{2}$/
      return Time.strptime(self, "%m/%d/%Y %H:%M")
    elsif self =~ /^\d{1,2}\/\d{1,2}\/\d{2} \d{1,2}:\d{2}$/
      return Time.strptime(self, "%m/%d/%y %H:%M")
    elsif self =~ /^\d{1,2}\/\d{1,2}\/\d{4} \d{2}:\d{2}:\d{2}$/
      return Time.strptime(self, "%m/%d/%Y %H:%M:%S")
    elsif self =~ /^\d{1,2}\/\d{1,2}\/\d{2} \d{2}:\d{2}:\d{2}$/
      return Time.strptime(self, "%m/%d/%y %H:%M:%S")
    elsif self =~ /^\d{4}\-/
      return Time.strptime(self, "%Y-%m-%d %H:%M:%S")
    else
      raise "Invalid time format for #{self}"
    end
  end
end
