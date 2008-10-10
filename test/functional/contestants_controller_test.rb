require 'test_helper'

class ContestantsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:contestants)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_contestant
    assert_difference('Contestant.count') do
      post :create, :contestant => { }
    end

    assert_redirected_to contestant_path(assigns(:contestant))
  end

  def test_should_show_contestant
    get :show, :id => contestants(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => contestants(:one).id
    assert_response :success
  end

  def test_should_update_contestant
    put :update, :id => contestants(:one).id, :contestant => { }
    assert_redirected_to contestant_path(assigns(:contestant))
  end

  def test_should_destroy_contestant
    assert_difference('Contestant.count', -1) do
      delete :destroy, :id => contestants(:one).id
    end

    assert_redirected_to contestants_path
  end
end
