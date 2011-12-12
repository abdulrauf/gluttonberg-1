module ApplicationHelper
  def current_localization_slug
     if @locale
       @locale.slug
     else
       Gluttonberg::Locale.first_default.slug
     end
  end

  def localized_text(english , chineese)
    (current_localization_slug == "cn" ? chineese : english ) 
  end
end
