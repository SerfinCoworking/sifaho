module AndesServices
  class FindSnomedConcept
    def initialize(params)
      @search_param = params[:search]
      @semantic_tag = params[:semantic_tag] || 'fármaco de uso clínico'
    end

    def call
      RestClient::Request.execute(method: :get, url: "#{ENV['ANDES_SNOMED_URL']}/",
                                  timeout: 120, headers: {
                                    params: { 'search': @search_param, 'semanticTag': @semantic_tag }
                                  })
    end
  end
end
