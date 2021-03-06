require 'tty-prompt'
require 'csv'
require 'erb'
require 'smarter_csv'
require_relative './classes/user'
require_relative './classes/folder'
require_relative './methods/methods'
require_relative './exceptions/exceptions'
require_relative './classes/boilerplate'

users_array = SmarterCSV.process("users_data.csv")
boilerplate_array = SmarterCSV.process("users_saved_boilerplates.csv")
# boilerplate_array.each {|x| puts x[:components_array]}
names_array = []
users_array.map{|user| names_array << user[:name]}

app_on = true
add_files_array = []
all_folders = []

if ARGV.empty?
    welcomeMsg
    sleep 2
    while app_on
        prompt = TTY::Prompt.new(symbols: {marker: '►'})
        user_menu_input = prompt.select("What would you like to do?") do |menu|
            menu.choice 'Signup', 1
            menu.choice 'Login', 2
            menu.choice 'Help', 3
            menu.choice 'Exit', 4
        end
        case user_menu_input 
        # New user sign up
        when 1
            system"clear"
            print "Username: "
            user_name = gets.chomp
            while user_name.empty?
                errorMsg
                print "Name cannot be an empty string, choose another name: "
                user_name = gets.chomp
            end
            puts User.checkIfNameExists(user_name, names_array)
            print "Password: "
            user_password = gets.chomp
            user = User.new(user_name, user_password, user_name)
            new_user_array = [user_name.split(' ').map(&:capitalize)*' ', user_password]
            CSV.open("users_data.csv", "a+") do |csv|
                csv << new_user_array
            end
            user_menu_input = prompt.select("What would you like to do next?") do |menu|
                menu.choice 'Start a new project', 1
                menu.choice 'Exit', 2
            end
            case user_menu_input
            # New user starting a new project
            when 1
                folder = Folder.new(@folder_name)
                folder.createFolder
                folder.addCSS?
                folder.addJavaScript?
                folder.writeFile
                user_menu_input = prompt.select("Would you like to open folder in VS Code?") do |menu|
                    menu.choice 'Yes', 1
                    menu.choice 'No', 2
                end
                case user_menu_input
                # Open project in VS Code
                when 1
                    system("code .")
                when 2
                end
                user_menu_input = prompt.select("Would you like to open index.html in your browser?") do |menu|
                    menu.choice 'Yes', 1
                    menu.choice 'No', 2
                end
                case user_menu_input
                # Open project in browser
                when 1
                    system("open ./index.html")
                when 2
                end               
                user_menu_input = prompt.select("Would you like to save current project in your boilerplates?") do |menu|
                    menu.choice 'Yes', 1
                    menu.choice 'No', 2
                end
                case user_menu_input
                # Save boilerplate and exit app
                when 1
                    Dir.chdir("..")
                    print "What would you like to call this boilerplate: "
                    boilerplate_name = gets.chomp
                    while boilerplate_name.empty?
                        errorMsg
                        print "Boilerplate name cannot be an empty string, choose another name: "
                        boilerplate_name = gets.chomp
                    end
                    boilerplate = Boilerplate.new(user.current_user, boilerplate_name)
                    new_boilerplate_array = [user.current_user, boilerplate_name, folder.all_files]
                    CSV.open("users_saved_boilerplates.csv", "a+") do |csv|
                        csv << new_boilerplate_array
                    end
                    puts "Your boilerplate was saved"
                    puts "Thank you for using HTML Boilerplate Creator"
                    puts "See you again soon"
                    sleep 2
                    farewellMsg
                    app_on = false
                when 2
                    # Exit app without saving boilerplate
                    puts "Thank you for visiting."
                    puts "See you again soon!"
                    sleep 2
                    farewellMsg
                    app_on = false
                end
            when 2
            end
        # Existing user log in
        when 2
            system"clear"
            print "Username: "
            username = gets.chomp
            print "Password: "
            password = gets.chomp
            puts User.authenticateUser(username, password, users_array)
            user_menu_input = prompt.select("What would you like to do next?") do |menu|
                menu.choice 'Start a new project', 1
                menu.choice 'View your boilerplates', 2
                menu.choice 'Exit', 3
            end
            case user_menu_input
            # Existing user start a new project
            when 1
                folder = Folder.new(@folder_name)
                folder.createFolder
                folder.addCSS?
                folder.addJavaScript?
                folder.writeFile
                user_menu_input = prompt.select("Would you like to open folder in VS Code?") do |menu|
                    menu.choice 'Yes', 1
                    menu.choice 'No', 2
                end
                case user_menu_input
                # Open code in VS Code
                when 1
                    system("code .")
                when 2
                    
                end
                user_menu_input = prompt.select("Would you like to open index.html in your browser?") do |menu|
                    menu.choice 'Yes', 1
                    menu.choice 'No', 2
                end
                case user_menu_input
                # Open code in browser
                when 1
                    system("open ./index.html")
                when 2
                    
                end               
                user_menu_input = prompt.select("Would you like to save current project in your boilerplates?") do |menu|
                    menu.choice 'Yes', 1
                    menu.choice 'No', 2
                end
                case user_menu_input
                # Save boilerplate and exit app
                when 1
                    Dir.chdir("..")
                    print "What would you like to call this boilerplate: "
                    boilerplate_name = gets.chomp
                    while boilerplate_name.empty?
                        errorMsg
                        print "Boilerplate name cannot be an empty string, choose another name: "
                        boilerplate_name = gets.chomp
                    end
                    boilerplate = Boilerplate.new(username, boilerplate_name)
                    new_boilerplate_array = [username, boilerplate_name, folder.all_files]
                    CSV.open("users_saved_boilerplates.csv", "a+") do |csv|
                        csv << new_boilerplate_array
                    end
                    puts "Your boilerplate was saved"
                    puts "Thank you for using HTML Boilerplate Creator"
                    puts "See you again soon"
                    sleep 2
                    farewellMsg
                    app_on = false
                # Exit app without saving boilerplate
                when 2
                    puts "Thank you for visiting."
                    puts "See you again soon!"
                    sleep 1
                    farewellMsg
                    app_on = false
                end
            # Existing user view saved boilerplates
            when 2
                Boilerplate.viewBoilerplates(username)
                loop do
                    user_menu_input = prompt.select("What would you like to do with your boilerplates?") do |menu|
                        menu.choice 'Use boilerplate', 1
                        menu.choice 'Change the name of a boilerplate', 2
                        menu.choice 'Delete a boilerplate', 3
                        menu.choice 'Exit', 4
                    end
                    case user_menu_input
                    when 1
                        featureUnfinished
                    when 2
                        featureUnfinished
                    when 3
                        featureUnfinished
                    when 4
                        system"clear"
                        farewellMsg
                        app_on = false
                        break 
                    end
                end
            # Exit the app
            when 3
                system"clear"
                farewellMsg
                app_on = false
            end
        # Display help message
        when 3
            system"clear"
            help
        # Exit the app
        when 4
            system"clear"
            farewellMsg
            app_on = false
        end
    end
elsif ARGV[0] == "-h" || ARGV[0] == "--help"
    puts "\n--- Help Menu ---"
    puts "\nInstallation:"
    puts "  To run this app"
    puts "  first execute 'bundle install'"
    puts "  then run 'ruby main.rb"
    puts "  alternativey run './run_app.sh"
    puts "  which will first download all gems needed for this app and then will launch the app."
    puts "\nRequirements:"
    puts "  VS Code is required if user chooses to run the created project file in code editor."
    puts "  Only tested on macOS Catalina Version 10.15.6. May not be compatible on other OS."
    puts "\nOptions:"
    puts "  -h or --help        # get help file\n\n"
end
