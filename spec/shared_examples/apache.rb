shared_context "openondemand::apache" do
  it do
    content = catalogue.resource('apache::custom_config', 'ood-portal').send(:parameters)[:content]
    puts content
  end
end
