class CatsController < ApplicationController
	def index
		@cats = Cat.all
	end

	def show
		@cat = Cat.find(params[:id])
	end

	def new
		@cat = Cat.new
	end

   def create
     @cat = Cat.new(post_params(:name, :color))
     @cat.save
     redirect_to cat_path(@cat)
   end

   def update
     @cat = Cat.find(params[:id])
     @cat.update(cat_params(:color))
     redirect_to cat_path(@cat)
   end

   def edit
     @cat = Cat.find(params[:id])
   end

   private

   def cat_params(*args)
       params.require(:cat).permit(*args)
   end

   end
