# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Helpers do

  describe ".meta_links_from_header" do
    it "should return a hash from the link header string" do
      link_header = "<http://sandbox.app.passaporteweb.com.br/organizations/api/accounts/?page=3&limit=3>; rel=next, <http://sandbox.app.passaporteweb.com.br/organizations/api/accounts/?page=1&limit=3>; rel=prev, <http://sandbox.app.passaporteweb.com.br/organizations/api/accounts/?page=123&limit=3>; rel=last, <http://sandbox.app.passaporteweb.com.br/organizations/api/accounts/?page=1&limit=3>; rel=first"
      described_class.meta_links_from_header(link_header).should == {
        limit: 3,
        next_page: 3,
        prev_page: 1,
        first_page: 1,
        last_page: 123
      }
    end
  end

  describe ".convert_to_ostruct_recursive" do
    it "should convert a hash recursevely to a OpenStruct" do
      hash = {a: 1, b: {c: 3, d: 4, e: {f: 6, g: 7}}}
      os = described_class.convert_to_ostruct_recursive(hash)
      os.should be_instance_of(OpenStruct)
      os.a.should == 1
      os.b.should be_instance_of(OpenStruct)
      os.b.c.should == 3
      os.b.d.should == 4
      os.b.e.should be_instance_of(OpenStruct)
      os.b.e.f.should == 6
      os.b.e.g.should == 7
    end
  end

end
