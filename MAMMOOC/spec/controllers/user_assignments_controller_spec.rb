require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe UserAssignmentsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # UserAssignment. As you add validations to UserAssignment, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UserAssignmentsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all user_assignments as @user_assignments" do
      user_assignment = UserAssignment.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:user_assignments)).to eq([user_assignment])
    end
  end

  describe "GET show" do
    it "assigns the requested user_assignment as @user_assignment" do
      user_assignment = UserAssignment.create! valid_attributes
      get :show, {:id => user_assignment.to_param}, valid_session
      expect(assigns(:user_assignment)).to eq(user_assignment)
    end
  end

  describe "GET new" do
    it "assigns a new user_assignment as @user_assignment" do
      get :new, {}, valid_session
      expect(assigns(:user_assignment)).to be_a_new(UserAssignment)
    end
  end

  describe "GET edit" do
    it "assigns the requested user_assignment as @user_assignment" do
      user_assignment = UserAssignment.create! valid_attributes
      get :edit, {:id => user_assignment.to_param}, valid_session
      expect(assigns(:user_assignment)).to eq(user_assignment)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new UserAssignment" do
        expect {
          post :create, {:user_assignment => valid_attributes}, valid_session
        }.to change(UserAssignment, :count).by(1)
      end

      it "assigns a newly created user_assignment as @user_assignment" do
        post :create, {:user_assignment => valid_attributes}, valid_session
        expect(assigns(:user_assignment)).to be_a(UserAssignment)
        expect(assigns(:user_assignment)).to be_persisted
      end

      it "redirects to the created user_assignment" do
        post :create, {:user_assignment => valid_attributes}, valid_session
        expect(response).to redirect_to(UserAssignment.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user_assignment as @user_assignment" do
        post :create, {:user_assignment => invalid_attributes}, valid_session
        expect(assigns(:user_assignment)).to be_a_new(UserAssignment)
      end

      it "re-renders the 'new' template" do
        post :create, {:user_assignment => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested user_assignment" do
        user_assignment = UserAssignment.create! valid_attributes
        put :update, {:id => user_assignment.to_param, :user_assignment => new_attributes}, valid_session
        user_assignment.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested user_assignment as @user_assignment" do
        user_assignment = UserAssignment.create! valid_attributes
        put :update, {:id => user_assignment.to_param, :user_assignment => valid_attributes}, valid_session
        expect(assigns(:user_assignment)).to eq(user_assignment)
      end

      it "redirects to the user_assignment" do
        user_assignment = UserAssignment.create! valid_attributes
        put :update, {:id => user_assignment.to_param, :user_assignment => valid_attributes}, valid_session
        expect(response).to redirect_to(user_assignment)
      end
    end

    describe "with invalid params" do
      it "assigns the user_assignment as @user_assignment" do
        user_assignment = UserAssignment.create! valid_attributes
        put :update, {:id => user_assignment.to_param, :user_assignment => invalid_attributes}, valid_session
        expect(assigns(:user_assignment)).to eq(user_assignment)
      end

      it "re-renders the 'edit' template" do
        user_assignment = UserAssignment.create! valid_attributes
        put :update, {:id => user_assignment.to_param, :user_assignment => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested user_assignment" do
      user_assignment = UserAssignment.create! valid_attributes
      expect {
        delete :destroy, {:id => user_assignment.to_param}, valid_session
      }.to change(UserAssignment, :count).by(-1)
    end

    it "redirects to the user_assignments list" do
      user_assignment = UserAssignment.create! valid_attributes
      delete :destroy, {:id => user_assignment.to_param}, valid_session
      expect(response).to redirect_to(user_assignments_url)
    end
  end

end