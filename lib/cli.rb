class Cli

    
    #add user variable
    @client_bedroom = 0
    @client_bathroom = 0
    @client_yard = true
    @client_location = ""
    @available_houses = []
    @house_addresses = []
    @user = nil

    def welcome_user
        puts "Welcome to Virtual Realtor"
        prompt = TTY::Prompt.new
        user_name = prompt.ask("May I get your name?")
        answer = Client.all.name.include? user_name
        if answer == false 
            @user = Client.create(name: user_name)
        end
    end

    def bedroom_prompt
        prompt = TTY::Prompt.new
        @client_bedroom = 
            prompt.select("How many bedrooms does your dream home have?", %w(1 2))
    end

    def bathroom_prompt
        prompt = TTY::Prompt.new
        @client_bathroom = 
            prompt.select("How many bathrooms does your dream home have?", %w(1 2))
    end

    def backyard_prompt
        prompt = TTY::Prompt.new
        @client_yard = 
            prompt.yes?("Does your dream home have a backyard?", convert: :boolean)
    end
    # comment
    def client_location
        prompt = TTY::Prompt.new
       @client_location =  prompt.select("What city would you like your dream home to be in?", %w(Denver Littleton Boulder))
    end
    
    def house_filter
        @available_houses = House.all.find_all do |house|
            house.bedrooms.to_i == @client_bedroom.to_i
        end.find_all do |house|
            house.bathrooms.to_i == @client_bathroom.to_i
        end.find_all do |house|
            house.yard == @client_yard
        end.find_all do |house|
            house.location.to_s == @client_location.to_s
        end
        @house_addresses = @available_houses.map do |house|
            house.address
        end
        n = @house_addresses.length
        puts "#{n} house(s) matches your selections!"
        puts @house_addresses
    end

    def view_house
        prompt = TTY::Prompt.new
        house_address = prompt.select("Which house would you like to view?", @house_addresses)
        puts "Great! You'll be viewing #{house_address}!"
        @house_view = House.find_by(address: house_address)
        return @house_view
    end

    def view_new_house
        prompt = TTY::Prompt.new
        @view_new_house = 
            prompt.yes?("Would you like to view a new house?", convert: :boolean)
        if @view_new_house == true
            self.view_house
            self.view_new_house
        else
            puts "No worries!"
        end
    end

    def list_viewing
        Viewing.create(client: @user, house: @house_view)
    end

    def houses_viewed
        puts "You have veiwed: "
        @houses_viewed = @user.viewings.map do |viewing|
            puts viewing.house.address
            viewing.house.address
        end
    end

    def buy_house
        prompt = TTY::Prompt.new
        @house_bought = prompt.select("Below are the houses you have viewed. Select the one you would like to buy.", @houses_viewed)
        puts "Congratulations! You just bought #{@house_bought}!"
    end

    def delete
        @user.destroy
        house_delete = House.find_by(address: @house_bought)
        house_delete.destroy
        puts "Available houses are now #{House.all.pluck(:address)}"
    end
    # Find way to display in cleaner fashion i.e. list
    # When delete is run, must re-input seeds into database and migrate. Find workaround


end
