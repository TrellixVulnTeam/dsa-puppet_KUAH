module Puppet::Parser::Functions
  newfunction(:allnodeinfo, :type => :rvalue) do |attributes|
    require '/etc/puppet/lib/puppet/parser/functions/ldapinfo.rb'
    return (function_ldapinfo('*', attributes))
  end
end
