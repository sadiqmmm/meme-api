require 'test_helper'

class MemesControllerTest < ActionController::TestCase
  setup do
    @meme = memes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:memes)
  end

  test "should create meme" do
    assert_difference('Meme.count') do
      post :create, meme: { bottom: @meme.bottom, link: @meme.link, top: @meme.top, type: @meme.type, user_id: @meme.user_id }
    end

    assert_response 201
  end

  test "should show meme" do
    get :show, id: @meme
    assert_response :success
  end

  test "should update meme" do
    put :update, id: @meme, meme: { bottom: @meme.bottom, link: @meme.link, top: @meme.top, type: @meme.type, user_id: @meme.user_id }
    assert_response 204
  end

  test "should destroy meme" do
    assert_difference('Meme.count', -1) do
      delete :destroy, id: @meme
    end

    assert_response 204
  end
end
