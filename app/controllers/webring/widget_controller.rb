module Webring
  class WidgetController < ::ApplicationController
    # Disable CSRF protection for widget.js as it needs to be loaded from other domains
    skip_forgery_protection

    # Set CORS headers for the widget
    before_action :set_cors_headers

    # Serve the webring navigation widget JavaScript
    # GET /widget.js
    def show
      respond_to do |format|
        format.js do
          response.headers['Content-Type'] = 'application/javascript'

          # Take the minified JavaScript file from the engine's assets and replace the customizable Logo SVG
          widget_js =
            Webring::Engine
            .root.join('app/assets/javascripts/webring/widget.min.js')
            .read
            .gsub('"<<REPLACE_ME_LOGO_SVG_FUNCTION>>"', logo_svg_function)
            .gsub('"<<REPLACE_ME_TEXT_DEFAULTS>>"', JSON.generate(text_defaults))

          render js: widget_js
        end
      end
    end

    private

    def set_cors_headers
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept'
      response.headers['Access-Control-Max-Age'] = '86400'
    end

    # This function is used to generate the logo SVG function for the compiled widget.js file to overcome args names compression issue
    def logo_svg_function
      <<~JS
        (width = 20, height = 20, style = "") => `#{logo_svg}`
      JS
    end

    # should include `${width}`, `${height}`, `${style}` in order to be customizable
    def logo_svg
      <<~HTML
        <svg width="${width}" height="${height}" style="${style}" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M13 3L6 14H12L11 21L18 10H12L13 3Z" fill="currentColor"/>
        </svg>
      HTML
    end

    # Provide default texts for the widget
    # Override this method to customize the default texts
    def text_defaults
      {
        prev: { default: 'Prev', enforced: false },
        random: { default: 'Random', enforced: false },
        next: { default: 'Next', enforced: false },
        widgetTitle: { default: 'Webring', enforced: false }
      }
    end
  end
end
