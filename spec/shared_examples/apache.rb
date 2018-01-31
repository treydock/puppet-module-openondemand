shared_context "openondemand::apache" do
  it do
    content = catalogue.resource('file', '/etc/ood/config/ood_portal.yml').send(:parameters)[:content]
    puts content
  end
end
