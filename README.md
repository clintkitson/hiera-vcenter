hiera-vcenter
=============
This is a VMware vCenter backend for the Hiera external node classifier (ENC) in Puppet.  The backend allows Custom Values set per Virtual Machine to be looked up to determine which classes need to applied for a Puppet Agent.  The Puppet Agent lives within the guest of the looked up Virtual Machine.

The Custom Values are held in a field per VM labled "puppet.classes".
