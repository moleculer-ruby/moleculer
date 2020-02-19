# frozen_string_literal: true
include YARD
include Templates


module TagTemplateHelper
  def linkify(*args)
    if args.first.is_a?(String)
      case args.first
      when /^render_method:(\S+)/
        path = $1
        obj = YARD::Registry.resolve(object, path)
        if obj
          opts = options.dup.merge(type: :method_details)
          opts.delete(:serializer)
          return obj.format(opts)
        else
          ""
        end
      end
    end
    super
  end
end

Template.extra_includes << TagTemplateHelper
