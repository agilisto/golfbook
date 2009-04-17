class PhotosController < ApplicationController

  def index
    sidebar :home
    if params[:user_id]
      @user = User.find(params[:user_id])
      @photos = @user.submitted_photos.paginate(:page => params[:page], :order => 'created_at desc')    #TODO: paginate this rather.
    else
      @photos = Photo.paginate(:page => params[:page], :order => 'created_at desc')
    end
  end

  def albums
    album_response = fbsession.photos_getAlbums
    @albums = album_response.album_list
    @albums.delete_if{|x|x.visible != 'everyone'}
    sidebar :home
  end

  def photos
    @album_id = params["album_id"]

    if @album_id
      @photos = fbsession.photos_get(:aid => @album_id).photo_list
    else
      flash[:error] = "Could not find the album - please try again."
      redirect_to :action => 'albums'
      return
    end
    sidebar :home
  end
  
  def create
    album_id = params["album_id"]
    photos = []
    params['photos'].each do |pid|
      new_photo = Photo.find_or_initialize_by_fb_photo_id(pid)
      new_photo.fb_album_id = album_id
      new_photo.user_id = @current_user.id
      new_photo.save
      puts new_photo.inspect
      Activity.log_activity(new_photo, Activity::ADDED, @current_user.id)
      photos << new_photo
    end

    publish_photo_added_action(photos.collect{|x|x.id})
    sidebar :home
    redirect_to :action => 'index'
  end

  def show
    @photo = Photo.find(params[:id])
  end

  def identify
    sidebar :home
    @photo = Photo.find(params[:id])
    unless params[:assets]
      if @photo
        @rounds = @current_user.rounds.recent(10)
        @courses = @current_user.courses_played
        fql =  "SELECT uid, name FROM user WHERE uid IN" +
          "(SELECT uid2 FROM friend WHERE uid1 = #{@user.facebook_uid}) " +
          "AND has_added_app = 1"
        friends_xml = fbsession.fql_query :query => fql
        @fql_friends = friends_xml.user_list
        @friends = User.find_all_by_facebook_uid(@fql_friends.collect{|x|x.uid}) + [current_user]
      else
        flash[:notice] = 'The photo could not be found.'
        redirect_to :action => 'index'
      end
    else  #this is with the form submitted
      @course = Course.find_by_name(params["course_filter"])
      @photo.photo_assets.destroy_all
      @photo_assets = []
      params['assets'].each do |asset_param|
        asset_type, asset_id = asset_param.split("_")
        @photo_assets << PhotoAsset.create(:asset_type => asset_type, :asset_id => asset_id, :photo_id => @photo.id)
      end
      @photo_assets << PhotoAsset.create(:asset_type => "Course", :asset_id => @course.id, :photo_id => @photo.id) unless @course.blank?
      Activity.log_activity(@photo, Activity::IDENTIFIED, @current_user.id)
      @photo_assets.each do |p|
        publish_asset_identified_action(p.id)
      end

      flash[:notice] = "Thank you! #{@photo_assets.size} items were identified."
      redirect_to :action => 'index', :user_id => @current_user.id
    end

  end

end


#      t.column :fb_album_id, :string
#      t.column :fb_photo_id, :string
#      t.column :user_id, :integer
