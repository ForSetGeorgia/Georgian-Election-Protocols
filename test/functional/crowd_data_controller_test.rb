require 'test_helper'

class CrowdDataControllerTest < ActionController::TestCase
  setup do
    @crowd_datum = crowd_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:crowd_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create crowd_datum" do
    assert_difference('CrowdDatum.count') do
      post :create, crowd_datum: @crowd_datum.attributes
    end

    assert_redirected_to crowd_datum_path(assigns(:crowd_datum))
  end

  test "should show crowd_datum" do
    get :show, id: @crowd_datum.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @crowd_datum.to_param
    assert_response :success
  end

  test "should update crowd_datum" do
    put :update, id: @crowd_datum.to_param, crowd_datum: @crowd_datum.attributes
    assert_redirected_to crowd_datum_path(assigns(:crowd_datum))
  end

  test "should destroy crowd_datum" do
    assert_difference('CrowdDatum.count', -1) do
      delete :destroy, id: @crowd_datum.to_param
    end

    assert_redirected_to crowd_data_path
  end
end
