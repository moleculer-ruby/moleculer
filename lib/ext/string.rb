# frozen_string_literal: true

##
# @private
class String
  def camelize
    str = split("_").map(&:capitalize).join
    str[0] = str[0].downcase
    str.gsub("Id", "ID")
  end

  def underscore
    gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
    gsub(/([a-z\d])([A-Z])/, '\1_\2').
    tr("-", "_").
    downcase
  end
end
