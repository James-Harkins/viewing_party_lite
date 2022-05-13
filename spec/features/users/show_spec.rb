require "rails_helper"

describe "User dashboard/show" do
  before do
    @user1 = User.create!(name: "User One", email: "user1@test.com")
    @user2 = User.create!(name: "User Two", email: "user2@test.com")
    @user3 = User.create!(name: "User Three", email: "user3@test.com")

    @u1_vp = Party.create!(event_date: DateTime.new(2002, 04, 26, 6, 0, 0, "-07:00"), duration: "230 mins", start_time: DateTime.new(2002, 04, 26, 6, 0, 0, "-07:00"), user_id: @user1.id, movie_id: 24021)
    @u1_vp_inv_1 = Invitation.create!(user_id: @user1.id, party_id: @u1_vp.id)
    @u1_vp_inv_2 = Invitation.create!(user_id: @user3.id, party_id: @u1_vp.id)

    @u2_vp = Party.create!(event_date: DateTime.new(2002, 02, 24, 7, 0, 0, "-07:00"), duration: "230 mins", start_time: DateTime.new(2002, 02, 24, 7, 0, 0, "-07:00"), user_id: @user2.id, movie_id: 809)
    @u2_vp_inv = Invitation.create!(user_id: @user3.id, party_id: @u2_vp.id)

    VCR.insert_cassette("has_a_section_that_lists_viewing_parties")
    visit "/users/#{@user1.id}"
  end

  after do
    VCR.eject_cassette
  end

  it "displays the users name" do

    expect(page).to have_content("User One's page")
    expect(page).not_to have_content("User Two's page")
  end

  it "has a button to discover movies" do
    click_button("Discover Movies")

    expect(current_path).to eq("/users/#{@user1.id}/discover")
    expect(current_path).not_to eq("/users/#{@user2.id}/discover")
  end

  it "has a section that lists viewing parties", :vcr do
    save_and_open_page
    within "#viewing_parties" do
      expect(page.find('#movie_poster')['src']).to have_content 'http://image.tmdb.org/t/p/w300/3mFM80dPzSqoXXuC2UMvLIRWX32.jpg'
      expect(page).to have_content("Party ##{@u1_vp.id}")
      expect(page).to have_link("Movie: The Twilight Saga: Eclipse")
      expect(page).to have_content("Date & Time: April 26, 2002 at 01:00")
      expect(page).to have_content("Host: User One")

      expect(page).not_to have_content("Host: User Two")
    end

    within "##{@u1_vp.id}-invited" do
      expect(page).to have_content("Invited: User One User Three")
    end
  end

  it "i see a link to go back to the landing page" do
    click_link("Return to Home Page")

    expect(current_path).to eq("/")
  end
end
