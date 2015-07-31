<%#
kind: finish
name: Preseed default finish
oses:
- Debian 6.0
- Debian 7.
- Debian 8.
- Ubuntu 10.04
- Ubuntu 12.04
- Ubuntu 13.04
- Ubuntu 14.04
%>
<%
  # safemode renderer does not support unary negation
  pm_set = @host.puppetmaster.empty? ? false : true
  puppet_enabled = pm_set || @host.params['force-puppet'] && @host.params['force-puppet'] == 'true'
  salt_enabled = @host.params['salt_master'] ? true : false
  chef_enabled = @host.respond_to?(:chef_proxy) && @host.chef_proxy
%>

<% subnet = @host.subnet -%>
<% if subnet.respond_to?(:dhcp_boot_mode?) -%>
  <% dhcp = subnet.dhcp_boot_mode? && !@static -%>
<% else -%>
  <% dhcp = !@static -%>
<% end -%>
<% unless dhcp -%>
# host and domain name need setting as these values may have come from dhcp if pxe booting
/bin/sed -i "s/^search.*$/search <%= @host.domain %>/g" /etc/resolv.conf
/bin/sed -i "s/.*dns-search.*/\tdns-search <%= @host.domain %>/g" /etc/network/interfaces
/bin/sed -i "s/^<%= @host.ip %>.*/<%= @host.ip %>\t<%= @host.shortname %>.<%= @host.domain %>\t<%= @host.shortname %>/g" /etc/hosts
/bin/echo <%= @host.shortname %> > /etc/hostname
<% end -%>
<% @host.interfaces.each do |interface| %>
echo '\ngot interface <%= interface.identifier %> with mac <%= interface.mac %>' >>/root/install_log
<% if interface.identifier != "" && interface.identifier != "ipmi" %>
echo '\nauto <%= interface.identifier %>\niface <%= interface.identifier %> inet dhcp' >>/etc/network/interfaces
<% end %>
<% end %>
<% if puppet_enabled %>
cat > /etc/puppet/puppet.conf << EOF
<%= snippet 'puppet.conf' %>
EOF
if [ -f "/etc/default/puppet" ]
then
/bin/sed -i 's/^START=no/START=yes/' /etc/default/puppet
fi
/bin/touch /etc/puppet/namespaceauth.conf
/usr/bin/puppet agent --enable
/usr/bin/puppet agent --config /etc/puppet/puppet.conf --onetime --tags no_such_tag <%= @host.puppetmaster.blank? ? '' : "--server #{@host.puppetmaster}" %> --no-daemonize
<% end -%>

<% if @host.info['parameters']['realm'] && @host.otp && @host.realm && @host.realm.realm_type == 'FreeIPA' -%>
<%= snippet 'freeipa_register' %>
<% end -%>

<% if salt_enabled %>
cat > /etc/salt/minion << EOF
<%= snippet 'saltstack_minion' %>
EOF
# Running salt-call to trigger key signing
salt-call --no-color --grains >/dev/null
<% end -%>

<% if chef_enabled %>
<%= respond_to?(:chef_bootstrap) ? chef_bootstrap(@host) : snippet_if_exists("chef-client omnibus bootstrap") %>
<% end%>

/usr/bin/wget --no-proxy --quiet --output-document=/dev/null --no-check-certificate <%= foreman_url %>
