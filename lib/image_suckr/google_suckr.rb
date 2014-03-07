module ImageSuckr
  
  class GoogleSuckr
    attr_accessor :default_params

    def initialize(options = {})
      options.reverse_merge!({
        rsz: '8',
        imgsz: 'xxlarge',
        v: '1.0',
        imgtype: 'photo',
        safe: 'active',
        q: '',
        salt: false
      })

      @default_params = options
    end

    def get_image_url options={}
      get_images_url(options).sample
    end

    def get_images_url options={}
      response_data = get_data options
      response_data["results"].map {|result| result["url"] }
    end

    def get_last_start options={}
      response_data = get_data options
      response_data["cursor"]["pages"].last["start"]
    end


    def get_image_content options={}
      Net::HTTP.get_response(URI.parse(get_image_url(options))).body
    end
    
    def get_image_file options={}
      open(URI.parse(get_image_url(options)))
    end

    private

    def get_data options={}
      params = @default_params.merge(options)
      params[:q] = params[:q]+' '+(params[:salt].is_a?(Fixnum) ? params[:salt] : rand(99999)).to_s if params[:salt].present?

      params = Hash[params.map{ |k,v| [k.to_s, v] }]

      url = "http://ajax.googleapis.com/ajax/services/search/images?" + params.to_query

      resp = Net::HTTP.get_response(URI.parse(url))
      result = JSON.parse(resp.body)
      result["responseData"]
    end

  end
end
