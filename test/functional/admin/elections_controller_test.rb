require 'test_helper'

class Admin::ElectionsControllerTest < ActionController::TestCase
  setup do
    @admin_election = admin_elections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_elections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_election" do
    assert_difference('Admin::Election.count') do
      post :create, admin_election: {  }
    end

    assert_redirected_to admin_election_path(assigns(:admin_election))
  end

  test "should show admin_election" do
    get :show, id: @admin_election
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_election
    assert_response :success
  end

  test "should update admin_election" do
    put :update, id: @admin_election, admin_election: {  }
    assert_redirected_to admin_election_path(assigns(:admin_election))
  end

  test "should destroy admin_election" do
    assert_difference('Admin::Election.count', -1) do
      delete :destroy, id: @admin_election
    end

    assert_redirected_to admin_elections_path
  end
end
