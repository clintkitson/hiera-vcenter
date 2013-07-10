hiera-vcenter
=============
This is a VMware vCenter backend for the Hiera external node classifier (ENC) in Puppet.  The backend allows Custom Values set per Virtual Machine to be looked up to determine which classes need to applied for a Puppet Agent.  The Puppet Agent lives within the guest of the looked up Virtual Machine.

The Custom Values are held in a field per VM labled "puppet.classes".

Install
=======
gem install rbvmomi
gem install hiera-vcenter

Requirements
============
Ruby 1.8.7+<br>
Hiera (included with Puppet 3)<Br>
Ensure Hiera is working with static yaml/json files for Node Classification first<br>
VM has "puppet.classes" custom value of a class name that is valid<br>

Configure
=========
1) Edit /etc/puppet/hiera.yaml and replace server, username (can be read-only account), and password for vCenter<Br>
2) Edit /etc/puppet/manifests/site.pp and add following line<Br>
hiera_include('classes')<br>

Run
===
Run Puppet Master interactively and watch the Node checkin and Hiera vCenter lookup "puppet master --no-daemonize --debug"
