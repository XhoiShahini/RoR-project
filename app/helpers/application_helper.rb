module ApplicationHelper
  include Pagy::Frontend

  def avatar_url_for(user, opts = {})
    size = opts[:size] || 48

    if user.respond_to?(:avatar) && user.avatar.attached? && user.avatar.variable?
      user.avatar.variant(
        thumbnail: "#{size}x#{size}^",
        gravity: "center",
        extent: "#{size}x#{size}"
      )
    else
      gravatar_url_for(user.email, size: size)
    end
  end

  def nav_link_to(title, path, options = {})
    options[:class] = Array.wrap(options[:class])
    active_class = options.delete(:active_class) || "active"
    inactive_class = options.delete(:inactive_class) || ""

    active = if (paths = Array.wrap(options[:starts_with])) && paths.present?
      paths.any? { |path| request.path.start_with?(path) }
    else
      request.path == path
    end

    classes = active ? active_class : inactive_class
    options[:class] << classes

    link_to title, path, options
  end

  def disable_with(text)
    "<i class=\"far fa-spinner-third fa-spin\"></i> #{text}".html_safe
  end

  def render_svg(name, options = {})
    options[:title] ||= name.underscore.humanize
    options[:aria] = true
    options[:nocomment] = true
    options[:class] = options.fetch(:styles, "fill-current text-gray-500")

    filename = "#{name}.svg"
    inline_svg_tag(filename, options)
  end

  def fa_icon(name, options = {})
    weight = options.delete(:weight) || "far"
    options[:class] = [weight, "fa-#{name}", options.delete(:class)]
    content_tag :i, nil, options
  end

  def badge(text, options = {})
    base = options.delete(:base) || "rounded-full py-1 px-4 text-xs inline-block font-bold leading-normal uppercase mr-2"
    color = options.delete(:color) || "bg-gray-400 text-gray-700"

    options[:class] = Array.wrap(options[:class]) + [base, color]

    content_tag :div, text, options
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def phone_number_field(form, phone_number)
    content_tag(:div, class: "form-group", data: { controller: "phone-number" }) do
      form.label(:phone_number) + \
      form.hidden_field(:phone_number, autocomplete: "off", data: { phone_number_target: "hidden" }) + \
      telephone_field_tag(
        "phone-input", 
        phone_number, 
        class: "phone-input form-control",
        data: {
          phone_number_target: "input",
          action: "blur->phone-number#update keyup->phone-number#reset change->phone-number#reset"
        }
      ) + \
      content_tag(
        :span,
        class: "hidden text-secondary-500",
        data: {
          phone_number_target: "valid"
        }) { fa_icon "check", weight: "fas" } + \
      content_tag(
        :div,
        class: "alert alert-error hidden",
        data: {
          phone_number_target: "error"
        }) { t("phone_number.invalid_number") }
    end
  end
end
