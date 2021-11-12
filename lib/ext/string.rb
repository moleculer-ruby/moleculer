# frozen_string_literal: true

##
# @private
class String
  # converts a ttring into a string suitable for a javascript object
  # "foo_bar" => "fooBar"
  def camelize
    str = split("_").map(&:capitalize).join
    str[0] = str[0].downcase
    str.gsub("Id", "ID")
  end
end
