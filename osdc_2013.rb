partition 'osdc' do
  label 'fw01',       :address => '192.168.192.2'
  label 'app01',      :address => '192.168.192.33'
  label 'app02',      :address => '192.168.192.34'
  label 'app subnet', :address => '192.168.192.0/24'

  rewrite 'public website' do
    ports 80, 443
    dnat 'fw01' => 'app01'
  end

  rewrite 'outbound' do
    snat 'app subnet' => 'fw01'
  end
end
