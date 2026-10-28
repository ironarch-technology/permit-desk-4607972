# Permit numbers are sequential within the year because that is how the
# counter has always issued them on paper.
class PermitNumbering
  def self.next_number
    year = Time.current.year
    prefix = "BP-#{year}-"
    last = PermitApplication.where('permit_number LIKE ?', "#{prefix}%").maximum(:permit_number)
    sequence = last ? last.split('-').last.to_i + 1 : 1
    format('%s%05d', prefix, sequence)
  end
end
