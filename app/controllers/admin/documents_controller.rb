class Admin::DocumentsController < Admin::BaseController

  access_control :DEFAULT => 'admin|editor'

  uses_tiny_mce :options => {
                              :theme => 'advanced',
                              :plugins => 'safari,pagebreak,style,layer,table,advhr,advlink,preview,contextmenu,paste,noneditable,nonbreaking,xhtmlxtras,media',
                              :theme_advanced_buttons1 => 'link,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,formatselect,fontsizeselect,html',
                              :theme_advanced_buttons2 => 'cut,copy,paste,pastetext,pasteword,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,code',
		              :theme_advanced_buttons3 => 'media,|,tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,advhr,|,ltr,rtl,|',
                              :theme_advanced_toolbar_location => 'top',
                              :theme_advanced_toolbar_align => 'left',
                              :theme_advanced_statusbar_location => 'bottom',
                              :theme_advanced_resizing => true
                            }

  def index
    @documents = Document.find(:all, :order => 'created_at ASC')
  end

  def show
    @document = Document.find(params[:id])
  end

  def new
    @document = Document.new
  end

  def edit
    @document = Document.find(params[:id])
  end

  def create
    help_doc = Document.first(:conditions => {:for_main_hint => true})

    @document = Document.new(params[:document])
    #Document.update_all("for_main_hint = false") if params[:document][:for_main_hint] && params[:document][:for_main_hint].to_i > 0

    if @document.save
      flash[:notice] = "Новый документ \"#{crop_text(@document.title,30)}\" создан"
      if @document.for_main_hint && help_doc && help_doc.id != @document.id
        help_doc.update_attributes(:for_main_hint => false)
      end
    else
      flash[:error] = 'Ошибка при добавлении документа'
    end
    redirect_to admin_documents_path
  end

  def update
    help_doc = Document.first(:conditions => {:for_main_hint => true})

    @document = Document.find(params[:id])
    #Document.update_all("for_main_hint = false") if params[:document][:for_main_hint] && params[:document][:for_main_hint].to_i > 0

    if @document.update_attributes(params[:document])
      flash[:notice] = "Документ \"#{crop_text(@document.title,30)}\" изменен"
      if @document.for_main_hint && help_doc && help_doc.id != @document.id
        help_doc.update_attributes(:for_main_hint => false)
      end
    else
      flash[:error] = 'Ошибка при редактировании документа'
    end
    redirect_to admin_documents_path
  end

  def destroy
    @document = Document.find(params[:id])
    tt = @document.title
    if @document.destroy
      flash[:notice] = "Документ \"#{crop_text(tt,30)}\" удален"
    else
      flash[:error] = "Ошибка при удалении документа"
    end
    redirect_to admin_documents_path
  end

end
