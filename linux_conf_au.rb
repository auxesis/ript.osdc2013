partition 'linux' do
  label 'linux.conf.au', :address => '192.168.192.2'
  label 'app-01',        :address => '192.168.192.33'
  label 'app-02',        :address => '192.168.192.34'
  label 'app subnet',    :address => '192.168.192.0/24'

  rewrite 'public website' do
    ports 80, 443
    dnat 'linux.conf.au' => 'app-01'
  end

  rewrite 'outbound' do
    snat 'app subnet' => 'linux.conf.au'
  end
end
