# Main Meme Controller. Certain code segments are pulled from examples from the memegen gem.
require "meme_generator"
require "meme_generator/cli"
require 'net/http'
require 'json'
class MemesController < ApplicationController
  # GET /memes
  # GET /memes.json
  def index
    if user_signed_in?
      # Only show the current user's memes
      @memes = current_user.memes
      render json: @memes
    else
      # If you aren't signed in, you are unauthorized
      head :unauthorized
    end
  end

  # GET /memes/1
  # GET /memes/1.json
  def show

    # We only show peple memes that belong to them so they must be signed in
    if user_signed_in?
      @meme = Meme.find(params[:id])
      # Check if user ids between memes and user match
      if @meme.user_id && @meme.user_id == current_user.id
        render json: @meme
      else
        # If their user id doesn't match the meme's user, they are unauthorized
        head :unauthorized
      end
    else
      # If they are not signed in, they are unauthorized
      head :unauthorized
    end
  end

  # POST /memes
  # POST /memes.json
  def create
    # Create a new meme
    @meme = Meme.new()

    # Like a traditional API, we don't require users to wrap meme data in a meme JSON object
    @meme.top = params[:top]
    @meme.bottom = params[:bottom]
    @meme.meme_type = params[:meme_type]

    # Find meme from meme image folder
    path = path_parse(@meme.meme_type)
    puts @meme.meme_type
    puts path
    if path
      # Create meme image
      output_path = MemeGenerator.generate(path, @meme.top, @meme.bottom)

      # Meme generator outputs a temporary file which we then upload to Imgur
      File.open(output_path, 'rb') { |f|

        # Use Imgur's API v3
        url = URI('https://api.imgur.com/3/image')
        Net::HTTP.start(url.hostname, url.port, {:use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE}) { |http|
          # Construct POST request

          post = Net::HTTP::Post.new url
          post['Authorization'] = 'Client-ID 6a69861ffe64207'

          # Send image in base 64
          post.set_form_data('image' => [f.read].pack('m'),
                             'type'  => 'base64')
          @body = JSON.parse http.request(post).body

          # If image has been uploaded properly, add the link to the meme object and a delete hash
          if @body["data"]["link"]
            @meme.link = @body["data"]["link"]
            @meme.deletehash = @body["data"]["deletehash"]
          # Else, do not save meme and output errors
          else
            render :json => { :errors => @body["data"] }, :status => :unprocessable_entity
            return
          end
        }
      }

      # Try to save the meme
      if @meme.save
        render json: @meme, status: :created, location: @meme
      else
        render json: @meme.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /memes/1
  # DELETE /memes/1.json
  def destroy
    if user_signed_in?
      @meme = Meme.find(params[:id])
      if @meme 
        url = URI('https://api.imgur.com/3/image/' + @meme.deletehash)
        Net::HTTP.start(url.hostname, url.port, {:use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE}) { |http|
          delete = Net::HTTP::Delete.new url
          body = JSON.parse http.request(delete).body
          puts body
          head :no_content
        }
      end
    else
      head :unauthorized
    end
  end

  private

    # Rails 4 params data
  	def meme_params
  		params.require(:meme_type).permit(:top, :bottom, :meme_type).merge(user: current_user)
  	end

    # Find image to use for meme
    def path_parse(string)
      if path = MemeGenerator.meme_paths.values.find { |p| p =~ /\/#{string}\..*$/ }
      else
        puts "Error: Image not found. Use --list to view installed images."
        exit 1
      end
      path
    end
end