require "spec_helper"
require "stringio"

describe "Deployment::Conf" do

  context "simple" do

    before(:all) do
      @content = {'key_0' => '0', 'key_1' => '1', 'key_2' => '2'}
    end

    it "loads" do
      file = StringIO.new %{key_0 : 0\nkey_1 : 1\nkey_2 : 2}
      Deployment::Conf.load_file(file).should == @content
    end

    it "dumps" do
      file = StringIO.new
      expected =<<-EOF
key_0 : 0
key_1 : 1
key_2 : 2
      EOF

      Deployment::Conf.dump(@content, file)
      file.string.should == expected
    end
  end

  context "with sub(s)" do

    it "loads"

    it "dumps sub" do
      content = { 'feature' => { 'sub' => {'key_0' => 'val 0', 'key_1' => 'val 1'}}}
      file = StringIO.new
      expected =<<-EOF
[feature]
[.sub]
key_0 : val 0
key_1 : val 1
      EOF

      Deployment::Conf.dump(content, file)
      file.string.should == expected
    end

    it "dumps sub-sub" do
      content = { 'feature' => { 'sub' => {'key_0' => 'val 0', 'sub_sub' => {'key_00' => 'val 00'}}}}
      file = StringIO.new
      expected =<<-EOF
[feature]
[.sub]
key_0 : val 0
[..sub_sub]
key_00 : val 00
      EOF

      Deployment::Conf.dump(content, file)
      file.string.should == expected
    end

    it "dumps sub sub" do
      content = { 'feature' => {
        'sub_0' => {'s0_k0' => 's0 v0', 's0_k1' => 's0 v1'},
        'sub_1' => {'s1_k0' => 's1 v0', 's1_k1' => 's1 v1'}}}
      file = StringIO.new
      expected =<<-EOF
[feature]
[.sub_0]
s0_k0 : s0 v0
s0_k1 : s0 v1
[.sub_1]
s1_k0 : s1 v0
s1_k1 : s1 v1
      EOF

      Deployment::Conf.dump(content, file)
      file.string.should == expected
    end

    it "dumps sub-sub sub" do
      content = { 'feature' => {
        'sub_0' => {'s0_k0' => 's0 v0', 'sub_0_0' => {'s0_s0_k0' => 's0 s0 v0'}},
        'sub_1' => {'s1_k0' => 's1 v0', 's1_k1' => 's1 v1'}}}
      file = StringIO.new
      expected =<<-EOF
[feature]
[.sub_0]
s0_k0 : s0 v0
[..sub_0_0]
s0_s0_k0 : s0 s0 v0
[.sub_1]
s1_k0 : s1 v0
s1_k1 : s1 v1
      EOF

      Deployment::Conf.dump(content, file)
      file.string.should == expected
    end

    it "dumps sub-sub-sub sub sub-sub" do
      content = {
        'feature' => {
          'sub_0' => {'s0_k0' => 's0 v0',
            'sub_0_0' => {'s0_s0_k0' => 's0 s0 v0',
              'sub_0_0_0' => {'s0_s0_s0_k0' => 's0 s0 s0 v0'}}},
          'sub_1' => {'s1_k0' => 's1 v0', 's1_k1' => 's1 v1'},
          'sub_2' => {'s2_k0' => 's2 v0',
            'sub_2_0' => {'s2_s0_k0' => 's2 s0 v0'}}
        }
      }
      file = StringIO.new
      expected =<<-EOF
[feature]
[.sub_0]
s0_k0 : s0 v0
[..sub_0_0]
s0_s0_k0 : s0 s0 v0
[...sub_0_0_0]
s0_s0_s0_k0 : s0 s0 s0 v0
[.sub_1]
s1_k0 : s1 v0
s1_k1 : s1 v1
[.sub_2]
s2_k0 : s2 v0
[..sub_2_0]
s2_s0_k0 : s2 s0 v0
      EOF

      Deployment::Conf.dump(content, file)
      file.string.should == expected
    end
  end

  context "with @sub(s)" do

    it "dumps @sub @sub" do
      content = {
        'feature' => {
          'sub' => [
            { 0 => {'host' => 'foo', 'lib' => 'vvv'}},
            { 1 => {'host' => 'bar', 'lib' => 'kkk'}}
          ]
        }
      }
      file = StringIO.new
      expected =<<-EOF
[feature]
[.@sub]
host : foo
lib : vvv
[.@sub]
host : bar
lib : kkk
      EOF

      Deployment::Conf.dump(content, file)
      file.string.should == expected
    end

    it "dumps @sub-sub @sub" do
      content = {
        'feature' => {
          'sub' => [
            { 0 => {'host' => 'foo', 'lib' => 'vvv', 'sub_0_0' => {'s0_s0_k0' => 's0 s0 v0', 's0_s0_k1' => 's0 s0 v1'}}},
            { 1 => {'host' => 'bar', 'lib' => 'kkk'}}
          ]
        }
      }
      file = StringIO.new
      expected =<<-EOF
[feature]
[.@sub]
host : foo
lib : vvv
[..sub_0_0]
s0_s0_k0 : s0 s0 v0
s0_s0_k1 : s0 s0 v1
[.@sub]
host : bar
lib : kkk
      EOF

      Deployment::Conf.dump(content, file)
      file.string.should == expected
    end

    it "dumps @sub-sub @sub @lib @lib" do
      content = {
        'feature' => {
          'sub' => [
            { 0 => {'host' => 'foo', 'lib' => 'vvv', 'sub_0_0' => {'s0_s0_k0' => 's0 s0 v0', 's0_s0_k1' => 's0 s0 v1'}}},
            { 1 => {'host' => 'bar', 'lib' => 'kkk'}}
          ],
          'lib' => [
            { 0 => {'l_k_0' => 'foo', 'l_k_1' => 'buz'}},
            { 1 => {'l_k_0' => 'bar', 'a_key' => 'a val'}}
          ]
        }
      }
      file = StringIO.new
      expected =<<-EOF
[feature]
[.@sub]
host : foo
lib : vvv
[..sub_0_0]
s0_s0_k0 : s0 s0 v0
s0_s0_k1 : s0 s0 v1
[.@sub]
host : bar
lib : kkk
[.@lib]
l_k_0 : foo
l_k_1 : buz
[.@lib]
l_k_0 : bar
a_key : a val
      EOF

      Deployment::Conf.dump(content, file)
      file.string.should == expected
    end

    it "dumps sub-sub-@lib @lib sub" do
      content = {
        'feature' => {
          'sub_0' => {'key_0' => 'val 0', 'sub_sub' => {
            'key_00' => 'val 00',
            'lib' => [
                {0 => {'s0_s0_k0' => 's0 s0 v0 foo', 's0_s0_k1' => 's0 s0 v1 foo'}},
                {1 => {'s0_s0_k0' => 's0 s0 v0 bar', 's0_s0_k1' => 's0 s0 v1 bar'}},
            ]}
          },
          'sub_1' => {'key_1' => 'val 1', 'key_2' => 'val 2'}
        }
      }
      file = StringIO.new
      expected =<<-EOF
[feature]
[.sub_0]
key_0 : val 0
[..sub_sub]
key_00 : val 00
[...@lib]
s0_s0_k0 : s0 s0 v0 foo
s0_s0_k1 : s0 s0 v1 foo
[...@lib]
s0_s0_k0 : s0 s0 v0 bar
s0_s0_k1 : s0 s0 v1 bar
[.sub_1]
key_1 : val 1
key_2 : val 2
      EOF

      Deployment::Conf.dump(content, file)
      file.string.should == expected
    end
  end

end