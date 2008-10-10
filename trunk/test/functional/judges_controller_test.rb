require 'test_helper'

class JudgesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:judges)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_judge
    assert_difference('Judge.count') do
      post :create, :judge => { }
    end

    assert_redirected_to judge_path(assigns(:judge))
  end

  def test_should_show_judge
    get :show, :id => judges(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => judges(:one).id
    assert_response :success
  end

  def test_should_update_judge
    put :update, :id => judges(:one).id, :judge => { }
    assert_redirected_to judge_path(assigns(:judge))
  end

  def test_should_destroy_judge
    assert_difference('Judge.count', -1) do
      delete :destroy, :id => judges(:one).id
    end

    assert_redirected_to judges_path
  end
end
