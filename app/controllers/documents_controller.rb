class DocumentsController < BaseController

  def show
    uri = params[:path].join('/')
    @document = Document.first(:conditions => {:key => uri})
    unless @document
      raise ActiveRecord::RecordNotFound
    end
  end

end
