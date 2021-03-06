include_recipe 'chef-sugar::default'

load_delivery_chef_config

site_name = 'docs'
domain_name = 'chef.io'

if node['delivery']['change']['stage'] == 'delivered'
  bucket_name = node['delivery']['change']['project'].gsub(/_/, '-')
  fqdn = "#{site_name}.#{domain_name}"
else
  bucket_name = "#{node['delivery']['change']['project'].gsub(/_/, '-')}-#{node['delivery']['change']['stage']}"
  fqdn = "#{site_name}-#{node['delivery']['change']['stage']}.#{domain_name}"
end

ruby_block 'check for a 200' do
  block do
    require 'rspec'
    require 'net/http'

    RSpec.describe "https://#{fqdn}/" do
      it 'should return 200' do
        uri = URI("https://#{fqdn}/")
        response = Net::HTTP.get_response(uri)
        expect(response.code.to_i).to eq(200)
      end
    end
  end
end
