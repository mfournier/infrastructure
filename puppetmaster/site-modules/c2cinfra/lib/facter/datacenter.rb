vlan = Facter.value(:vlans)
addr = Facter.value(:ipaddress)

if vlan.is_a?(String) and vlan.split(',').include?('192')
  Facter.add('datacenter') do
    setcode do
      'c2corg'
    end
  end
else
  Facter.add('datacenter') do
    setcode do
      case addr
        when /^192\.168\.192/ then 'c2corg'
        when /^128\.179\.66/  then 'epnet'
        when /^95\.142/       then 'gandi'
        else 'other'
      end
    end
  end
end
