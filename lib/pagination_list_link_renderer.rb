class PaginationListLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer

  protected

    def page_number(page)
      unless page == current_page
        tag(:li, link(page, page, :rel => rel_value(page)))
      else
        tag(:li, link(page, "#", :rel => rel_value(page)), :class => "active")
      end
    end

    def previous_or_next_page(page, text, classname)
      if page
        tag(:li, link(text, page), :class => classname)
      else
        tag(:li, link(text, "#"), :class => classname + ' disabled')
      end
    end

    def html_container(html)
      tag(:ul, html, container_attributes)
    end
    
    def default_url_params
      {}
    end

    def gap
      text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
      %(<li class="disabled"><a href="#">#{text}</a></li>)
    end

    def url(page)
      @base_url_params ||= begin
        url_params = merge_get_params(default_url_params)
        merge_optional_params(url_params)
      end

      url_params = @base_url_params.dup
      add_current_page_param(url_params, page)

      @template.url_for(url_params)
    end
    
    def merge_get_params(url_params)
      if @template.respond_to? :request and @template.request and @template.request.get?
        symbolized_update(url_params, @template.params)
      end
      url_params
    end

    def merge_optional_params(url_params)
      symbolized_update(url_params, @options[:params]) if @options[:params]
      url_params
    end

    def add_current_page_param(url_params, page)
      unless param_name.index(/[^\w-]/)
        url_params[param_name.to_sym] = page
      else
        page_param = parse_query_parameters("#{param_name}=#{page}")
        symbolized_update(url_params, page_param)
      end
    end

end