require 'test_helper'

class PageantsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pageants)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pageant" do
    assert_difference('Pageant.count') do
      post :create, :pageant => { }
    end

    assert_redirected_to pageant_path(assigns(:pageant))
  end

  test "should show pageant" do
    get :show, :id => pageants(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => pageants(:one).to_param
    assert_response :success
  end

  test "should update pageant" do
    put :update, :id => pageants(:one).to_param, :pageant => { }
    assert_redirected_to pageant_path(assigns(:pageant))
  end

  test "should destroy pageant" do
    assert_difference('Pageant.count', -1) do
      delete :destroy, :id => pageants(:one).to_param
    end

    assert_redirected_to pageants_path
  end
end
