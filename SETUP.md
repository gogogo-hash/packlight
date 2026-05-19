# Packlight Rails Setup Guide

## Ruby Environment Setup (Required First)

Your WSL Ubuntu environment doesn't have Ruby installed yet. You need Ruby 3.4.9.

### Option 1: Using rbenv (Recommended)
```bash
# Install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
source ~/.bashrc

# Install ruby-build plugin
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby 3.4.9
rbenv install 3.4.9
rbenv global 3.4.9
ruby --version  # Should show ruby 3.4.9
```

### Option 2: Using asdf
```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
echo 'source $HOME/.asdf/asdf.sh' >> ~/.bashrc
source ~/.bashrc
asdf plugin add ruby
asdf install ruby 3.4.9
asdf global ruby 3.4.9
```

## Setup Commands (Run After Ruby is Installed)

Once Ruby 3.4.9 is installed in WSL:

```bash
cd /home/coryc/packlight

# Install gems
bundle install

# Initialize databases (development & test)
rails db:create
rails db:schema:load

# Generate Devise models
bundle exec rails generate devise:install
bundle exec rails generate devise User admin:boolean
bundle exec rails generate devise_invitable User

# Run migrations
bundle exec rails db:migrate

# Generate other models
bundle exec rails generate model Item name:string description:text price:decimal file_folder_path:string status:string last_scanned_at:datetime
bundle exec rails generate model Photo item:references file_name:string image_data:binary order:integer
bundle exec rails generate model Comment item:references user:references content:text
bundle exec rails generate model Subscription subscribable:references{polymorphic} user:references

# Run all migrations
bundle exec rails db:migrate

# Start the server
bundle exec rails server
```

## Database Setup

Make sure PostgreSQL is running in WSL:
```bash
sudo service postgresql start
```

Or use Docker:
```bash
docker run --name packlight-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16
```
