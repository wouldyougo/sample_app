class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :index, :show, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
 
  def index
    #@users = User.all
    @users = User. paginate(page: params[:page])
    #@users = User. paginate(page: params[:page], :per_page => 50)
    #@users = User. paginate(page: params[:page], :per_page => 10).order('name DESC')
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])    
  end  

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      #запись cookies в sign_in в модуле SessionsHelper 
      sign_in @user 
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      #flash[:error] = "Возникла ошибка при создании нового пользователя."
      render 'new'
    end
  end  
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end  

  def edit
    #заменено на before_action :correct_user
    #@user = User.find(params[:id])    
  end
  
  def update
    #заменено на before_action :correct_user
    #@user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      #flash[:error] = "Возникла ошибка при редактировании пользователя."
      render 'edit'
    end
  end
  
  # following (читаемые)
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  # followers (читатели)
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  private
    #ограничивает набор разрешенных параметров
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
       
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end    
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end   
end

  
