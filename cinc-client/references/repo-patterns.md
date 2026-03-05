# Cinc Repository Patterns

## Cookbook Internal Structure

```
cookbooks/<name>/
├── metadata.rb          # name, version, depends
├── Policyfile.rb        # policy-based dependency management
├── Policyfile.lock.json
├── Rakefile             # version bump tasks
├── recipes/             # individual .rb recipe files
├── files/               # static files deployed to nodes
├── templates/           # ERB templates for dynamic config
├── test/integration/default/  # InSpec tests
└── kitchen.yml          # Test Kitchen config
```

## Recipe Patterns

Keep recipes small and single-responsibility:

```ruby
# Install a package
package 'curl'

# Deploy a template
template '/etc/app/config.conf' do
  source 'config.conf.erb'
  variables(
    setting: node['cookbook']['setting']
  )
  notifies :restart, 'service[app]'
end

# Manage a service
service 'nginx' do
  action [:enable, :start]
end

# Create a user
user 'deploy' do
  home '/home/deploy'
  shell '/bin/bash'
  manage_home true
end
```

## Data Bag Usage

```ruby
# Load user from data_bags/users/
user_data = data_bag_item('users', 'tcase')

# Load with encryption
secret = Chef::EncryptedDataBagItem.load_secret('/etc/cinc/encrypted_data_bag_secret')
vault_item = Chef::EncryptedDataBagItem.load('vault', 'secrets', secret)

# Iterate over data bag items
data_bag('users').each do |user_id|
  u = data_bag_item('users', user_id)
  # use u['name'], u['uid'], u['groups'], etc.
end
```

## Role Composition

Roles combine to build node configurations:

```json
{
  "run_list": [
    "role[debian_derivative]",
    "role[local_essentials]",
    "role[ekamai]",
    "role[devmachine]"
  ]
}
```

Common roles:
- `debian_derivative` — base OS config (packages, timezone, sudo)
- `local_essentials` — essential local tools
- `ekamai` — Bangkok timezone, QNAP/location settings
- `devmachine` — Docker, neovim, tmux, AWS CLI, Postgres, Redis, etc.
- `desktop` — GUI apps (1Password, Spotify, Chrome, Kitty, Obsidian, etc.)
- `pihole` — Pi-hole DNS/DHCP server
- `remote_access` — SSH and remote access config

## Node JSON Structure

```json
{
  "name": "hostname",
  "run_list": [
    "role[debian_derivative]",
    "role[devmachine]"
  ],
  "normal": {
    "base": {
      "users": ["tcase"]
    }
  }
}
```

## InSpec Test Pattern

```ruby
# test/integration/default/default_test.rb
describe package('curl') do
  it { should be_installed }
end

describe service('nginx') do
  it { should be_running }
  it { should be_enabled }
end

describe file('/etc/app/config.conf') do
  it { should exist }
  its('content') { should match /expected_value/ }
end
```

## Attribute Precedence (low → high)

`default` → `normal` → `override` → `automatic (ohai)`

Set in: cookbook defaults, roles (default_attributes/override_attributes), node JSON (normal).
