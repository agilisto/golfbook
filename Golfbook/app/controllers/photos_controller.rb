class PhotosController < ApplicationController

  def index
    sidebar :home
    if params[:user_id]
      @photos = @current_user.submitted_photos.find(:all, :order => 'created_at desc', :limit => 20)    #TODO: paginate this rather.
    else
      @photos = Photo.find(:all, :order => 'created_at desc', :limit => 20)
    end
  end

  def albums
    album_response = fbsession.photos_getAlbums
    @albums = album_response.album_list
    sidebar :home
  end

  def photos
    @album_id = params["album_id"]
    @photos = fbsession.photos_get(:aid => @album_id).photo_list
    sidebar :home
  end
  
  def create
    params['photos'].each do |pid|
      photo = Photo.create(:fb_album_id => params["album_id"], :fb_photo_id => pid, :user_id => @current_user.id)
    end
    sidebar :home
    redirect_to :action => 'index'
  end

  def identify
    sidebar :home
    unless params[:assets]
      if (@photo = @current_user.submitted_photos.find(params[:id]))
        @rounds = @current_user.rounds.recent(10)
        @courses = @current_user.courses_played
        fql =  "SELECT uid, name FROM user WHERE uid IN" +
          "(SELECT uid2 FROM friend WHERE uid1 = #{@user.facebook_uid}) " +
          "AND has_added_app = 1"
        friends_xml = fbsession.fql_query :query => fql
        @fql_friends = friends_xml.user_list
        @friends = User.find_all_by_facebook_uid(@fql_friends.collect{|x|x.uid})
      else
        flash[:notice] = 'The photo could not be found.'
        redirect_to :action => 'index'
      end
    else  #this is with the form submitted
      @photo_assets = []
      params['assets'].each do |asset_param|
        asset_type, asset_id = asset_param.split("_")
        @photo_assets << PhotoAsset.create(:asset_type => asset_type, :asset_id => asset_id, :photo_id => params[:photo_id])
      end
      flash[:notice] = "Thank you! #{@photo_assets.size} items were identified."
      redirect_to :action => 'index', :user_id => @current_user.id
    end

  end

end


#      t.column :fb_album_id, :string
#      t.column :fb_photo_id, :string
#      t.column :user_id, :integer
