require 'resolv'

class DnsCheck
	attr_reader :host
	def initialize(host)
		@host = host
	end

	def a
		@a ||= Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::A)
	end

	def a?
		a.any?
	end

	def mx
		@mx ||= Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::MX)
	end

	def mx?
		mx.any?
	end

	def ns
		@ns ||= Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::NS)
	end

	def ns?
		ns.any?
	end

	def cname
    @cname ||= Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::CNAME)
  end

  def cname?
    cname.any?
  end

  def ip
    Resolv.getaddress(host)
  end

end

puts DnsCheck.new('juliendesrosiers.ca').ip
puts DnsCheck.new('test.juliendesrosiers.ca').cname?
puts DnsCheck.new('www.juliendesrosiers.ca').ip
