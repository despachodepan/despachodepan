class CardsController < ApplicationController
  layout 'admin'
  before_filter :authenticate
  inherit_resources

  def find
    redirect_to Card.find_by_url(params[:id])
  end

  def index
    @cards = Card.all(:include => [:color, :main_image, :main_slide, :tags])
    index!
  end

  def new
    card = Card.create(:title => 'ficha sin título')
    expire_page_cache(card)
    redirect_to edit_card_path(card)
  end

  def update
    @card = Card.find(params[:id])
    if @card.update_attributes(params[:card])
      flash[:notice] = 'Bien!! Ficha guardada!'
      expire_page_cache(@card)
      if data?(:main_data)
        @card.main_image.destroy if @card.main_image
        image = Image.create(:uploaded_data => params[:main_data])
        @card.update_attribute(:main_image_id, image.id)
      end
      if data?(:selection_image_data)
        @card.selection_image.destroy if @card.selection_image
        image = Image.create(:uploaded_data => params[:selection_image_data])
        @card.update_attribute(:selection_image_id, image.id)
      end
      redirect_to edit_card_path(@card)
    else
      prepare_edit
      render :action => 'edit'
    end
  end

  def show
    redirect_to :action => 'edit'
  end

  def edit
    prepare_edit
    edit!
  end

  private
  def prepare_edit
    @card = Card.find(params[:id]) if @card.nil?
    @tags = Tag.all
    @colors = Color.all
    @photo = @card.slides.build(:rol => 'slide')
    @news = @card.slides.build(:rol => 'news')
    @selected = @card.slides.build(:rol => 'selection')
    @card_file = CardFile.new(:card_id =>  @card.id)
  end



end
