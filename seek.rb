partition 'seek' do
  label 'www.seek.com.au', :address => '202.58.38.95'
  label 'app-01',          :address => '10.3.4.2'
  label 'app-02',          :address => '10.3.4.3'
  label 'app subnet',      :address => '10.3.4.0/24'

  rewrite 'public website' do
    ports 80, 443
    dnat 'www.seek.com.au' => 'app-01'
  end

  rewrite 'outbound' do
    snat 'app subnet' => 'www.seek.com.au'
  end
end
