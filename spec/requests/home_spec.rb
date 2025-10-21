# spec/requests/home_spec.rb
require "rails_helper"

RSpec.describe "Homes", type: :request do
     describe "GET / (home#index)" do
          it "returns http success" do
               allow(HomePageStore).to receive(:read).and_return(
                 {
                   "hero_badge_html"            => "<b>We are LEGION</b>",
                   "who_we_are_title"           => "Who we are",
                   "who_we_are_body_html"       => "<p>Body</p>",
                   "partner_title"              => "Our Partner",
                   "partner_body_html"          => "<p>Partner body</p>",
                   "footer_diversity_title"     => "Diversity Statement",
                   "footer_diversity_body_html" => "<p>Diversity body</p>"
                 }
               )

            get root_path

            expect(response).to have_http_status(:ok)
            expect(response.body).to include("Who we are")
          end
     end
end
