%w[camping eventmachine em-http faye].each { |r| require r }

Camping.goes :RequestHeaders
module RequestHeaders
  module Models
    class Sites
      def self.search(sites)
        p sites
        client = Faye::Client.new('http://localhost:9292/faye') 
        multi = EM::MultiRequest.new
        sites.each do |s|
          multi.add(EM::HttpRequest.new(s).get)
        end

        multi.callback {
          multi.responses[:succeeded].each do |h|
            p h.methods.sort
            client.publish('/sites/success', 'status'  => h.response_header.status, 'header' => h.response_header)
          end
          multi.responses[:failed].each do |h|
            client.publish('/sites/failure', 'text'  => 'failure')
          end
        }
      end
    end # Sites
    
  end # Models

  module Controllers
    class Index
      def get
        render :index 
      end
    end # Index

    class ShowHeaders < R '/search'
      def post
        urls = input.search_urls.chomp.split(',')
        Sites.search(urls)
      end # post
    end # ShowHeaders < R '/search'
    
    module Helpers
      def helper_title
        title = "Simple Headers Requester"
        if @title.nil?
          title 
        else
          "#{title} | " + @title
        end
      end
    end # Helpers

    def load_css(href)
      # TODO: this method should load all css from href attribute
      link :rel => 'stylesheet', :type => 'text/css', :href => href, :media => 'screen'
    end
    def load_script(src)
      # TODO: this method should load all javascripts from src attribute
      script :src => src , :type => 'text/javascript' do
        text ""
      end
    end
  end # Controllers

  module Views
    def layout
      html do
        head do
          title helper_title
          load_css "public/css/styles.css"
          load_script '/faye.js'
          load_script 'public/javascripts/mustache.js'
          load_script 'public/javascripts/jquery-1.6.2.js'
          load_script 'public/javascripts/jQueryMustache.js'
          load_script 'public/javascripts/application.js'
        end
        body do
          h1 { a 'Headers requester', :href => R(Index) }
          div.wrapper! do
            text yield
          end
        end
      end
    end

    def index
      h1 "Welcome to Headers Requester"
      form.remote! :action => R(ShowHeaders), :method => 'post' do
        label "Enter coma separated urls:", :for => 'search_urls'; br
        input.search_urls! :name => 'search_urls', :type => 'text'
        input :value => 'search', :type => 'submit'
      end
      div.responses!
    end

  end # Views
end 
