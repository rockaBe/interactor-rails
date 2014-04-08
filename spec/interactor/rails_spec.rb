require "spec_helper"

module Interactor
  describe "Rails" do
    describe "w/o testing framework" do
      before do
        run_simple <<-CMD
          bundle exec rails new example \
            --skip-gemfile \
            --skip-bundle \
            --skip-git \
            --skip-keeps \
            --skip-active-record \
            --skip-sprockets \
            --skip-javascript \
            --skip-test-unit \
            --quiet
          CMD
        cd "example"
        write_file "Gemfile", <<-EOF
          gem "rails"
          gem "interactor-rails", path: "#{ROOT}"
          EOF
        run_simple "bundle install"
      end

      describe "rails generate" do
        describe "interactor" do
          it "generates an interactor" do
            run_simple "bundle exec rails generate interactor place_order"

            path = "app/interactors/place_order.rb"
            check_file_presence([path], true)
            check_exact_file_content(path, <<-EOF)
class PlaceOrder
  include Interactor

  def perform
    # TODO
  end
end
EOF
          end

          it "requires a name" do
            run_simple "bundle exec rails generate interactor"

            check_file_presence(["app/interactors/place_order.rb"], false)
            assert_partial_output("rails generate interactor NAME", all_stdout)
          end
        end

        describe "interactor:organizer" do
          it "generates an organizer" do
            run_simple <<-CMD
              bundle exec rails generate interactor:organizer place_order
              CMD

            path = "app/interactors/place_order.rb"
            check_file_presence([path], true)
            check_exact_file_content(path, <<-EOF)
class PlaceOrder
  include Interactor::Organizer

  # organize Interactor1, Interactor2
end
EOF
          end

          it "generates an organizer with interactors" do
            run_simple <<-CMD
              bundle exec rails generate interactor:organizer place_order \
                charge_card fulfill_order
              CMD

            path = "app/interactors/place_order.rb"
            check_file_presence([path], true)
            check_exact_file_content(path, <<-EOF)
class PlaceOrder
  include Interactor::Organizer

  organize ChargeCard, FulfillOrder
end
EOF
          end

          it "requires a name" do
            run_simple "bundle exec rails generate interactor:organizer"

            check_file_presence(["app/interactors/place_order.rb"], false)
            assert_partial_output("rails generate interactor:organizer NAME", all_stdout)
          end
        end
      end

      it "auto-loads interactors" do
        run_simple "bundle exec rails generate interactor place_order"

        run_simple "bundle exec rails runner PlaceOrder"
      end

      it "auto-loads organizers" do
        run_simple "bundle exec rails generate interactor:organizer place_order"

        run_simple "bundle exec rails runner PlaceOrder"
      end
    end
  end

  describe "with testing framework" do

    describe "using rspec" do
      before do
        run_simple <<-CMD
          bundle exec rails new example \
            --skip-gemfile \
            --skip-bundle \
            --skip-git \
            --skip-keeps \
            --skip-active-record \
            --skip-sprockets \
            --skip-javascript \
            --skip-test-unit \
            --quiet
          CMD
        cd "example"
        write_file "Gemfile", <<-EOF
          gem "rails"
          gem "rspec-rails"
          gem "interactor-rails", path: "#{ROOT}"
          EOF
        run_simple "bundle install"
        run_simple "bundle exec rails generate rspec:install"
      end

      describe "for interactors" do
        before do
          run_simple "bundle exec rails generate interactor place_order"
        end

        it "generates folder" do
          check_directory_presence(["spec/interactors"], true)
        end

        it "generates file" do
          path = "spec/interactors/place_order_spec.rb"
          check_file_presence([path], true)
          check_file_content(path, 'describe "PlaceOrder" do', true)
          check_file_content(path, 'class PlaceOrder', false)
        end
      end

      describe "for organizers" do
        before do
          run_simple <<-CMD
            bundle exec rails generate interactor:organizer order_place \
                        order place
          CMD
        end

        it "generates file" do
          path = "spec/interactors/order_place_spec.rb"
          check_file_presence([path], true)
          check_file_content(path, 'describe "OrderPlace" do', true)
          check_file_content(path, 'class OrderPlace', false)
        end
      end

    end

    describe "using rails test" do
      before do
        run_simple <<-CMD
          bundle exec rails new example \
            --skip-gemfile \
            --skip-bundle \
            --skip-git \
            --skip-keeps \
            --skip-active-record \
            --skip-sprockets \
            --skip-javascript \
            --quiet
          CMD
        cd "example"
        write_file "Gemfile", <<-EOF
          gem "rails"
          gem "interactor-rails", path: "#{ROOT}"
          EOF
        run_simple "bundle install"
      end

      describe "generating files" do
        describe "for interactors" do
          before do
            run_simple "bundle exec rails generate interactor place_order"
          end

          it "generates folder for interactors" do
            check_directory_presence(["test/interactors"], true)
          end

          it "generates file for interactor" do
            path = "test/interactors/place_order_test.rb"
            check_file_presence([path], true)
            check_file_content(path, 'class PlaceOrder', true)
            check_file_content(path, 'describe "PlaceOrder" do', false)
          end
        end

        describe "for organizers" do
          before do
            run_simple <<-CMD
              bundle exec rails generate interactor:organizer order_place \
                          order place
            CMD
          end

          it "generates file" do
            path = "test/interactors/order_place_test.rb"
            check_file_presence([path], true)
            check_file_content(path, 'class OrderPlace', true)
            check_file_content(path, 'describe "OrderPlace" do', false)
          end
        end
      end
    end

  end
end
