#!/usr/bin/env rspec

require 'spec_helper'

provider_class = Puppet::Type.type(:puppet_auth).provider(:augeas)
def valid_lens?
  # This lens breaks on Augeas 0.10.0
  Puppet::Util::Package.versioncmp(Puppet::Type.type(:puppet_auth).provider(:augeas).aug_version, '0.10.0') > 0
end

describe provider_class, :if => valid_lens? do
  before :each do
    FileTest.stubs(:exist?).returns false
    FileTest.stubs(:exist?).with('/etc/puppet/auth.conf').returns true
  end

  context "with empty file" do
    let(:tmptarget) { aug_fixture("empty") }
    let(:target) { tmptarget.path }

    it "should create simple new entry" do
      apply!(Puppet::Type.type(:puppet_auth).new(
        :name          => "/facts rule",
        :path          => "/facts",
        :authenticated => "any",
        :target        => target,
        :provider      => "augeas",
        :ensure        => "present"
      ))

      aug_open(target, "Puppet_Auth.lns") do |aug|
        expect(aug.match("path").size).to eq(1)
        expect(aug.get("path")).to eq("/facts")
        expect(aug.match("path/operator").size).to eq(0)
        expect(aug.get("path/auth")).to eq("any")
      end
    end
  end

  context "with full file" do
    let(:tmptarget) { aug_fixture("full") }
    let(:target) { tmptarget.path }

    it "should list instances" do
      provider_class.stubs(:target).returns(target)
      inst = provider_class.instances.map { |p|
        {
          :name => p.get(:name),
          :ensure => p.get(:ensure),
          :path => p.get(:path),
          :path_regex => p.get(:path_regex),
          :environments => p.get(:environments),
          :methods => p.get(:methods),
          :allow => p.get(:allow),
          :allow_ip => p.get(:allow_ip),
          :authenticated => p.get(:authenticated),
        }
      }

      expect(inst.size).to eq(9)
      expect(inst[0]).to eq({:path_regex=>:true, :methods=>["find"], :environments=>[], :authenticated=>:absent, :allow=>["$1"], :allow_ip=>[], :ensure=>:present, :name=>"Auth rule matching ^/catalog/([^/]+)$", :path=>"^/catalog/([^/]+)$"})
      expect(inst[2]).to eq({:path_regex=>:false, :methods=>["find"], :environments=>[], :authenticated=>:absent, :allow=>["*"], :allow_ip=>[], :ensure=>:present, :name=>"Auth rule for /certificate_revocation_list/ca", :path=>"/certificate_revocation_list/ca"})
      expect(inst[7]).to eq({:path_regex=>:false, :methods=>["find", "save"], :environments=>[], :authenticated=>"any", :allow=>["*"], :allow_ip=>[], :ensure=>:present, :name=>"Auth rule for /certificate_request", :path=>"/certificate_request"})
    end

    describe "when creating settings" do
      it "should create a simple new entry" do
        apply!(Puppet::Type.type(:puppet_auth).new(
          :name          => "/facts before first deny",
          :path          => "/facts",
          :environments  => ["staging", "stable"],
          :methods       => "find",
          :authenticated => "any",
          :ins_before    => "first deny",
          :target        => target,
          :provider      => "augeas",
          :ensure        => "present"
        ))

        aug_open(target, "Puppet_Auth.lns") do |aug|
          expect(aug.get("path[last()-1]")).to eq("/facts")
          expect(aug.get("path[.='/facts']/environment/1")).to eq("staging")
          expect(aug.match("path[.='/facts']/method/*").size).to eq(1)
          expect(aug.get("path[.='/facts']/method/1")).to eq("find")
        end
      end

      it "should create an entry with a regex path" do
        apply!(Puppet::Type.type(:puppet_auth).new(
          :name          => "Matching ^/foo/([^/]+)$",
          :path          => "^/foo/([^/]+)$",
          :path_regex    => "true",
          :authenticated => "any",
          :target        => target,
          :provider      => "augeas",
          :ensure        => "present"
        ))

        aug_open(target, "Puppet_Auth.lns") do |aug|
          expect(aug.get("path[.='^/foo/([^/]+)$']/operator")).to eq('~')
        end
      end
    end

    describe "when modifying settings" do
      it "should modify the properties" do
        apply!(Puppet::Type.type(:puppet_auth).new(
          :name          => "Apply /certificate/ to staging",
          :path          => "/certificate/",
          :environments  => "staging",
          :authenticated => "on",
          :allow         => ["localhost.localdomain", "example.com"],
          :allow_ip      => "192.168.0.1/32",
          :target        => target,
          :provider      => "augeas",
          :ensure        => "present"
        ))

        aug_open(target, "Puppet_Auth.lns") do |aug|
          expect(aug.get("path[.='/certificate/']/environment/1")).to eq("staging")
          expect(aug.get("path[.='/certificate/']/auth")).to eq("on")
          expect(aug.get("path[.='/certificate/']/allow/1")).to eq("localhost.localdomain")
          expect(aug.get("path[.='/certificate/']/allow/2")).to eq("example.com")
          expect(aug.get("path[.='/certificate/']/allow_ip/1")).to eq("192.168.0.1/32")
        end
      end

      it "should remove the save method" do
        apply!(Puppet::Type.type(:puppet_auth).new(
          :name        => "Remove save method from /certificate_request",
          :path        => "/certificate_request",
          :methods     => "find",
          :target      => target,
          :provider    => "augeas",
          :ensure      => "present"
        ))

        aug_open(target, "Puppet_Auth.lns") do |aug|
          expect(aug.match("path[.='/certificate_request']/method").size).to eq(1)
          expect(aug.get("path[.='/certificate_request']/method/1")).to eq("find")
        end
      end

      it "should remove the entry" do
        apply!(Puppet::Type.type(:puppet_auth).new(
          :name        => "Remove save method from /certificate_request",
          :path        => "/certificate_request",
          :target      => target,
          :provider    => "augeas",
          :ensure      => "absent"
        ))

        aug_open(target, "Puppet_Auth.lns") do |aug|
          expect(aug.match("path[.='/certificate_request']").size).to eq(0)
        end
      end
    end
  end

  context "with broken file" do
    let(:tmptarget) { aug_fixture("broken") }
    let(:target) { tmptarget.path }

    it "should fail to load" do
      txn = apply(Puppet::Type.type(:puppet_auth).new(
        :name     => "Test broken",
        :path     => "/facts",
        :target   => target,
        :provider => "augeas",
        :ensure   => "present"
      ))

      expect(txn.any_failed?).not_to eq(nil)
      expect(@logs.first.level).to eq(:err)
      expect(@logs.first.message.include?(target)).to eq(true)
    end
  end
end
