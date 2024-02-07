module ObfuscationHelper
  # obfuscated_link_to path, text, html_options
  # obfuscated_link_to path, html_options, do
  #    [block]
  def obfuscated_link_to(*args, &block)
    if block_given?
      path = args[0]
      html_options = args[1] || {}
      if html_options && html_options[:class]
        html_options[:class] += " lnkobf"
      else
        html_options[:class] = "lnkobf"
      end
      html_options[:role] = "link"
      html_options[:tabindex] = "0"
      html_options["data-target"] = Base64.encode64(path)
      content_tag "a", html_options do
        yield block
      end
    else
      anchor = args[0]
      path = args[1]
      html_options = args[2]
      obfuscated_link_to path, html_options do
        anchor
      end
    end
  end
end
